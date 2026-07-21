---
name: goodday-api
description: >
  Call the goodday work-management API v2 for Projects, Tasks, and Users — list/read/create/update
  projects, folders, and tasks; comment, reply, tag, and change task status; read users and
  rate history. Use when the user wants to query or manage goodday projects, tasks, or users, or
  mentions goodday API routes, a gd-api-token, or api.goodday.work.
---

# goodday API v2 — Projects, Tasks & Users

REST API for goodday work management. Base URL: `https://api.goodday.work/2.0` — **HTTPS only**, the API does not answer over HTTP.

## Authentication

Every request carries the API token in the `gd-api-token` header. Read it from the environment variable `GOODDAY_API_TOKEN` — never hardcode a token into code or a command.

```sh
curl -H "gd-api-token: $GOODDAY_API_TOKEN" https://api.goodday.work/2.0/projects
```

If `GOODDAY_API_TOKEN` is unset, stop and tell the user to export it (the token comes from their goodday *Organization → Settings → API* screen); do not proceed without it.

## Conventions

- All write routes (POST/PUT) identify the acting user with a user-id field in the JSON body — `userId`, `fromUserId`, or `createdByUserId` as noted per route. This is required.
- Dates are `YYYY-MM-DD` strings. On `PUT /task/{TASK-ID}/update`, sending `null` for a nullable field resets it.
- `{PROJECT-ID}`, `{TASK-ID}`, `{TAG-ID}`, `{USER-ID}` are path segments you substitute with real IDs.

## The complete route set

The routes below are the **entire** Projects, Tasks, and Users surface of the goodday API v2 — this is all of them. No other Projects, Tasks, or Users routes exist. Do not invent paths, guess endpoints, or assume an unlisted operation is available; if a capability is not listed here, the API does not offer it.

### Projects & Folders

| Method | Path | Purpose |
|---|---|---|
| GET | `/projects` | List company projects |
| GET | `/project/{PROJECT-ID}` | Get one project's details |
| PUT | `/project/{PROJECT-ID}` | Update a project |
| POST | `/projects/new-folder` | Create a folder |
| POST | `/projects/new-project` | Create a project |

**GET `/projects`** — query params: `archived` (bool, default `false`), `rootOnly` (bool, default `false`). Returns an array of project objects (`id`, `name`, `description`, dates, status, `customFieldsData`).

**GET `/project/{PROJECT-ID}`** — no params. Returns one project with settings (`workItems`, `customFields`, `workflow`, `taskTypes`).

**PUT `/project/{PROJECT-ID}`** — body: `userId` (string, **required**); optional `name`, `description`, `color` (int 1–24), `health` (int 0/1/2), `statusComments`, `parentProjectId`, `ownerUserId`, `startDate`, `endDate`, `priority` (int), `estimate` (int minutes), `progress` (int 0–100), `statusId`, `systemStatus` (int — `2` = reopen).

**POST `/projects/new-folder`** — body: `createdByUserId` (**required**), `name` (**required**); optional `parentProjectId`, `color` (int 1–24). Returns the folder object.

**POST `/projects/new-project`** — body: `createdByUserId` (**required**), `projectTemplateId` (**required**), `name` (**required**); optional `parentProjectId`, `color` (int 1–24), `projectOwnerUserId`, `startDate`, `endDate`, `deadline`. Returns the new project with its generated `id`.

### Tasks

| Method | Path | Purpose |
|---|---|---|
| GET | `/project/{PROJECT-ID}/tasks` | List a project's tasks |
| GET | `/tag/{TAG-ID}/tasks` | List tasks with a tag |
| GET | `/user/{USER-ID}/action-required-tasks` | List a user's action-required tasks |
| GET | `/user/{USER-ID}/assigned-tasks` | List tasks assigned to a user |
| GET | `/task/{TASK-ID}` | Get one task's details |
| GET | `/task/{TASK-ID}/messages` | List a task's messages/comments |
| POST | `/tasks` | Create a task or subtask |
| POST | `/task/{TASK-ID}/comment` | Comment on a task |
| POST | `/task/{TASK-ID}/reply` | Reply / change the action-required user |
| POST | `/task/{TASK-ID}/tag/{TAG-ID}` | Add a tag to a task |
| PUT | `/task/{TASK-ID}/status` | Change a task's status |
| PUT | `/task/{TASK-ID}/update` | Update a task's fields |

**GET `/project/{PROJECT-ID}/tasks`** — query params: `closed` (bool, default `false`), `subfolders` (bool, default `false`).

**GET `/tag/{TAG-ID}/tasks`** — query param: `closed` (bool, default `false`).

**GET `/user/{USER-ID}/action-required-tasks`** — no params.

**GET `/user/{USER-ID}/assigned-tasks`** — query param: `closed` (bool, default `false`).

**GET `/task/{TASK-ID}`** — no params. Returns the full task, including subtasks.

**GET `/task/{TASK-ID}/messages`** — no params. Returns an array of messages (`id`, `dateCreated`, `message`, `fromUserId`).

**POST `/tasks`** — body: `projectId` (**required**), `title` (**required**), `fromUserId` (**required**); optional `parentTaskId` (for a subtask), `message`, `toUserId`, `taskTypeId`, `startDate`, `endDate`, `deadline`, `estimate` (int minutes), `storyPoints` (int), `priority` (int 1–10), `crmContactIds` (string[]), `crmAccountId`. Returns `{ id, momentCreated, shortId }`.

**POST `/task/{TASK-ID}/comment`** — body: `userId` (**required**); optional `message`.

**POST `/task/{TASK-ID}/reply`** — body: `userId` (**required**), `actionRequiredUsedId` (**required**, the new action-required user); optional `message`.

**POST `/task/{TASK-ID}/tag/{TAG-ID}`** — body: `userId` (**required**).

**PUT `/task/{TASK-ID}/status`** — body: `userId` (**required**), `statusId` (**required**); optional `message`.

**PUT `/task/{TASK-ID}/update`** — body: `userId` (**required**); optional (send `null` to reset where noted): `title`, `projectId` (move to another project), `parentTaskId` (make it a subtask), `startDate`, `endDate`, `deadline`, `scheduleDate`, `priority` (int), `estimate` (int minutes), `progress` (int 0–100), `storyPoints` (int), `assignedToUserId`, `todoList` (JSON).

### Users

| Method | Path | Purpose |
|---|---|---|
| GET | `/users` | List organization users |
| GET | `/user/{USER-ID}` | Get one user's details |
| GET | `/user/{USER-ID}/hourly-rate-history` | List a user's hourly-rate history |

**GET `/users`** — query param: `deleted` (bool, optional — include deleted users). Returns an array of user objects (`id`, `companyRole`, `isAdmin`, `momentCreated`, `name`, `primaryEmail`, `reportsToUserId`, `departmentId`, `departmentName`, `laborRate`, `serviceRate`, `phoneNumber`, `skills`, `customFields`).

**GET `/user/{USER-ID}`** — no params. Returns one user object (same fields as above).

**GET `/user/{USER-ID}/hourly-rate-history`** — no params. Returns an array of rate records (`id`, `laborRate`, `serviceRate`, `startMoment`, `endMoment`).
