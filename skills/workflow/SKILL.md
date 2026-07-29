---
name: workflow
description: >
  Durable, type-safe queue workers with @falcondev-oss/workflow on Redis.
  Use when working with WorkflowNamespace / createWorkflow, step.do / step.wait /
  step.waitUntil, workflow.run / runIn / runAt / work(), job.wait(),
  upsertSchedule cron schedules, groupId ordering and numeric priority, or the
  Settings / createRedis connection setup.
---

# @falcondev-oss/workflow

A long-running async process — send an email, sleep three days, send a follow-up — dies with the process that runs it. This library makes it survivable: the workflow body is an ordinary async function, but every `step` it takes is persisted to Redis, so a crash, deploy, or retry **replays** the function from the top and skips straight past the steps that already finished.

Three layers, each minted by the one above:

| Layer | Owns |
|---|---|
| `WorkflowNamespace` | The redis connection, the pub/sub connection, a cross-workflow concurrency cap |
| `Workflow` | One queue + one job type: input schema, `run` body, its worker |
| `WorkflowJob` | One enqueued run: `id`, `groupId`, `wait()` |

Everything is exported from the package root: `WorkflowNamespace`, `Settings`, `createRedis`, `expBackoff`, `TimeoutError`, `ResultExpiredError`, `JobAlreadyExistsError`.

> The package README still shows `new Workflow({ … })` with no namespace. That constructor is namespace-bound — always go through `namespace.createWorkflow()`.

## Setting up

```ts
import { createRedis, Settings, WorkflowNamespace } from '@falcondev-oss/workflow'

Settings.logger = console // opt-in; no logging by default
Settings.defaultConnection = async () => createRedis({ url: process.env.REDIS_URL })

const namespace = new WorkflowNamespace({ id: 'app' })
```

`Settings` is a global with three optional fields: `logger` (`info`/`success`/`error`/`debug`/`warn`, all optional), `defaultConnection`, and `metrics`. `createRedis` applies the connection options the library needs (`maxRetriesPerRequest: null`, offline queue off, a capped retry strategy) — build connections with it rather than `new IORedis()`. Pass `redis` on the namespace to override the default connection per namespace.

The namespace registers its own exit hook, so `SIGTERM` drains workers and disconnects. Call `namespace.close()` explicitly in tests.

## Defining a workflow

```ts
const onboarding = namespace.createWorkflow({
  id: 'onboarding',
  schema: z.object({ userId: z.string(), name: z.string() }),
  getGroupId: (input) => input.userId,
  async run({ input, step }) {
    await step.do('welcome', () => sendWelcome(input.userId))
    await step.wait('settle', 3 * 24 * 60 * 60 * 1000)
    const engaged = await step.do('check engagement', () => isEngaged(input.userId))
    return { engaged }
  },
})
```

- **`id`** scopes every redis key for this workflow. Changing it orphans in-flight jobs.
- **`schema`** is any [Standard Schema](https://standardschema.dev) (zod, arktype, …), and validates twice: at enqueue and again in the worker. A failure throws `Invalid workflow input`. Omit it and `input` is typed `undefined`.
- **`getGroupId`** derives the group from validated input; an explicit `groupId` on the run call wins over it.
- **`run`** receives `{ input, step, span }` and its resolved value becomes the job output. Payload, step results, and output all round-trip through superjson, so `Date`, `Map`, `Set`, and `BigInt` survive intact.
- `queueOptions` / `workerOptions` / `jobOptions` set per-workflow defaults; the same keys on the namespace are shallow-merged underneath them. See [`reference/options.md`](reference/options.md).

## Running jobs

```ts
await onboarding.work() // start a worker in this process

const job = await onboarding.run({ userId: 'u1', name: 'John' })
const { engaged } = await job.wait() // typed as the run() return
```

`run(input, opts?)` enqueues now, `runIn(input, delayMs, opts?)` after a delay, `runAt(input, date, opts?)` at a timestamp. All three resolve to a `WorkflowJob` as soon as it is enqueued — they do not wait for it to execute. `opts` accepts `groupId`, `priority`, `maxAttempts`, and `jobId`.

`job.wait(timeoutMs?)` blocks on a pub/sub notification and returns the deserialized output. It works from a pure producer with no worker in the process. It rejects with:

| Error | When |
|---|---|
| the workflow's own `Error` | `run` threw and exhausted its attempts — the original message is preserved |
| `TimeoutError` | `timeoutMs` elapsed first (no default; waits forever without it) |
| `ResultExpiredError` | the job finished but its result record aged out of `resultTtl` (default 300 s) |

Passing an explicit `jobId` that is already in use rejects with `JobAlreadyExistsError` — the deduplication handle for "enqueue this at most once".

## Steps and replay

`step.do(name, run)` is the unit of durability. It memoizes **on completion**: once it returns, its result is written to the job's step hash, and any later attempt returns the cached value without re-running the body. So a retry replays completed steps instantly and re-executes only the step that failed.

```ts
const user = await step.do('load user', () => db.user.find(input.userId))
await step.do('charge', async ({ step, span }) => {
  span.setAttribute('user.plan', user.plan)
  await step.do('authorize', () => gateway.authorize(user)) // nested → 'charge|authorize'
  await step.do('capture', () => gateway.capture(user))
})
```

The callback receives `{ step, span }`: a nested `step` whose names are prefixed with the parent's (`parent|child`), and the OTel span for the step. Step names are the memoization key — **keep them stable and unique within a job**, and treat renaming a step as invalidating its cached result.

`step.wait(name, durationMs)` is a durable sleep: it persists `startedAt` on first entry, so a replay sleeps only the *remaining* time rather than the full duration again. `step.waitUntil(name, date)` is the same thing against an absolute time.

Three properties worth holding onto:

- **No step-level retry.** `step.do` takes no options bag; a throw fails the whole job, and retries are job-level (`maxAttempts`).
- **Cancellation is cooperative.** A worker that loses its claim (lock stolen, heartbeat lost) aborts the job's signal: `step.wait` rejects immediately, and `step.do` refuses to *start* new work — but a step already running is not interrupted. Long CPU-bound steps hold their slot until they return.
- **`Promise.all` over steps does not cancel siblings.** When one parallel step throws, the others keep running to completion; the job failure waits for them (and logs a warning). Sequence steps that must not outlive a failure.

Since replay re-executes the function body around the cached steps, keep everything outside a step pure — side effects between steps run on every attempt.

## Ordering, grouping, and concurrency

A **group** is a serialized lane: jobs sharing a `groupId` run one at a time, in FIFO order, and a job blocks its group until it finishes. Without a `groupId` (or `getGroupId`), every job gets a random UUID group and is fully parallel. Use the entity id — `userId`, `tenantId` — as the group to serialize per-entity work.

`priority` is a plain number, 0…2²¹-1, higher first, default 0. There is no `'high' | 'normal'` enum.

Four independent ceilings, all optional:

| Cap | Where | Default |
|---|---|---|
| Across all workflows in a namespace | `WorkflowNamespace({ concurrency })` | unlimited |
| Across all workers of one workflow | `queueOptions.concurrency` | unlimited |
| Within one group | `queueOptions.groupConcurrency` | 1 |
| Within one worker process | `workerOptions.concurrency` / `work({ concurrency })` | 1 |

The default worker concurrency of 1 is the usual surprise: `work()` alone processes one job at a time per process.

## Retries

`maxAttempts` defaults to **1** — no retry. It is applied per job at enqueue time, so a value set in `workerOptions` only takes effect for jobs enqueued by a producer that shares those options; prefer `jobOptions.maxAttempts` or the per-run `opts.maxAttempts` when producer and worker are separate processes.

Backoff is worker-side and per-workflow: `workerOptions.backoff(attempt)` returns ms before the given (1-based) attempt, defaulting to `expBackoff()` — exponential with full jitter, `base` 500 ms, `factor` 2, `cap` 30 s. `backoff: () => 0` is the standard test override.

## Cron schedules

```ts
await onboarding.upsertSchedule('nightly-digest', {
  pattern: '0 3 * * *',
  input: { userId: 'system', name: 'digest' },
  tz: 'Europe/Berlin',
})
```

`upsertSchedule(scheduleId, opts)` is idempotent — re-upserting an id replaces it in place, so it is safe to call on every boot. `input` is validated against the schema right there, so a bad payload fails at registration rather than at 3 am. Options: `pattern` (Croner syntax — cron patterns only, no interval form), `input`, `tz` (IANA, defaults to the registering process's local zone), `priority`, `groupId` (defaults to the `scheduleId`, which serializes occurrences), and `skipIfRunning` (default `true` — a slow run suppresses the next tick instead of piling up). A backlog of missed fires collapses to a single run.

`removeSchedule(scheduleId)` and `getSchedules()` complete the surface; the latter returns `{ scheduleId, pattern, tz, nextRun, lastFireAt, lastJobId }` per schedule.

## Observability

Tracing is automatic when an OTel SDK is registered: producer spans propagate context into the payload, so the worker's job span and each step span link back to whatever enqueued the job. The `span` in `run`'s and `step.do`'s context is that live span — set attributes on it directly.

Queue-depth metrics are opt-in via `Settings.metrics` or `workerOptions.metrics`, both `{ meter, prefix }`, registered when `work()` is called. See [`reference/options.md`](reference/options.md) for the exported gauges and the full worker tuning surface (`lockMs`, `maxStalledCount`, `stalledInterval`, `safetyTimeout`, `promoteBatchSize`, `keepFailed`, `onError`, `onFailed`).
