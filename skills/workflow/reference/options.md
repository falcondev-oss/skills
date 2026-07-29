# Option reference

Every option bag below can be set on the namespace (as a default for its workflows), on
`createWorkflow`, and — for worker and job options — at the call site. The merge is shallow, one
level deep, with the more specific bag winning key by key: `namespace → createWorkflow → work()` /
`run()`.

## `new WorkflowNamespace(opts)`

| Option | Default | Meaning |
|---|---|---|
| `id` | — | Namespace id; scopes the cross-workflow concurrency cap |
| `concurrency` | unlimited | Ceiling across every workflow in the namespace |
| `redis` | `Settings.defaultConnection()` | Shared connection, owned by the namespace (it is duplicated once for pub/sub) |
| `prefix` | `wf` | Global redis key prefix |
| `queueOptions` | — | Defaults for its workflows |
| `workerOptions` | — | ″ |
| `jobOptions` | — | ″ |

## `queueOptions`

Applied when the workflow's queue is first created (on the first `work()` / `run()`).

| Option | Default | Meaning |
|---|---|---|
| `concurrency` | unlimited | Ceiling across every worker of this workflow |
| `groupConcurrency` | `1` | Jobs per group running at once — `1` is what serializes a group |
| `resultTtl` | `300` | Seconds the finished result record is kept. `job.wait()` past this window throws `ResultExpiredError` |

## `jobOptions` / per-run `opts`

The same keys accepted as the second argument of `run` / `runIn` / `runAt`.

| Option | Default | Meaning |
|---|---|---|
| `groupId` | random UUID | Serialization lane. Precedence: per-run `opts` → `getGroupId(input)` → `jobOptions` |
| `priority` | `0` | Number, 0…2²¹-1, higher runs first |
| `maxAttempts` | `1` | Job-level attempts, stamped at enqueue time |
| `jobId` | random UUID | Explicit id; a live collision throws `JobAlreadyExistsError` |

`runAt` and `runIn` are set by the `runAt()` / `runIn()` methods and are mutually exclusive — they
are not accepted in the options bag.

## `workerOptions` / `work(opts)`

| Option | Default | Meaning |
|---|---|---|
| `concurrency` | `1` | Jobs this process runs at once |
| `maxAttempts` | `1` | Fallback attempts default, used only when the producer shares these options |
| `backoff` | `expBackoff()` | `(attempt: number) => number` ms before the given (1-based) attempt |
| `lockMs` | `30_000` | Lock/heartbeat TTL held while a job runs. The heartbeat renews ~3× within it (capped at 10 s); a lost renewal aborts the job's signal |
| `maxStalledCount` | `1` | Times a job may be recovered from a stall before it is failed permanently |
| `stalledInterval` | `30_000` | Min ms between stalled-recovery scans, across all workers |
| `safetyTimeout` | `5` | Backstop re-poll timeout in **seconds** (the loop is otherwise woken by pub/sub) |
| `promoteBatchSize` | `500` | Max due delayed jobs promoted per reserve; larger backlogs drain in chunks |
| `keepFailed` | `100` | Max retained failed jobs, trimmed by finish time |
| `onError` | `Settings.logger.error` | Called with a worker-internal/unexpected error |
| `onFailed` | `Settings.logger.error` | Called with `(job, error)` each time a handler throws and the job fails |
| `metrics` | `Settings.metrics` | `{ meter, prefix }` — see below |

`onFailed`'s `job` is a frozen `ReservedJob`: `{ id, groupId, data, attemptsMade, priority }`, where
`data` is the still-serialized payload.

`expBackoff(opts?)` takes `{ base = 500, factor = 2, cap = 30_000 }` and returns a uniform random
delay in `[0, min(cap, base * factor^(attempt-1))]` ms — full jitter, so retries spread out.

## Metrics

Set `Settings.metrics` globally or `workerOptions.metrics` per workflow, both `{ meter, prefix }`
where `meter` is an OTel `Meter`. Registered on `work()`, they publish three observable gauges,
each carrying a `workflow_id` attribute:

- `<prefix>_workflow_active_jobs` — claimed and running
- `<prefix>_workflow_waiting_jobs` — queued across active groups
- `<prefix>_workflow_delayed_jobs` — parked for a future run time

They are point-in-time reads of redis, taken when the meter collects — not counters the library maintains.
