---

## name: browser-bug-reproduction
description: Browser-based bug reproduction via localhost:3000 or direct gql-api requests. Covers environment setup, dev server management, login, repro step execution, error tracing, and evidence capture. Use whenever a command needs to visually verify or reproduce a bug in the running webapp or API.

# Browser Bug Reproduction

Reproduce a bug by running the local dev stack and exercising it through the browser or direct API requests. The calling command provides reproduction steps, org, environment, and any reference material (screenshots, videos); this skill handles the mechanics.

## Reproduction modes

Choose a mode based on where the bug is suspected:

- **Full UI** (default): start both `@fg/gql-api` and `@fg/webapp`, reproduce via the browser at `http://localhost:3000/`.
- **API-only**: start only `@fg/gql-api`, reproduce by sending requests directly to the gql-api endpoint (e.g. via `curl` or the GraphQL playground). Use this when the bug is (or is likely) in the API layer -- it avoids the overhead of the webapp and provides more direct feedback.

The calling command or your own judgement determines which mode to use. If a bug initially appears UI-related but browser reproduction reveals it originates from gql-api responses, switch to API-only mode for faster iteration.

## Steps

### 1. Configure environment

If a specific environment is needed (e.g. the work item has a `FoundInEnvironment` field, or the user requests one), delegate to `/set-igw` to configure `INTERNAL_GATEWAY` in `packages/apps/gql-api/.env`.

Otherwise skip -- default config is sufficient for most cases.

### 2. Start dev servers

Check whether the relevant servers are already running by inspecting terminal output files.

- **Full UI mode**: run `pnpm dev` on both `@fg/gql-api` and `@fg/webapp`.
- **API-only mode**: run `pnpm dev` on `@fg/gql-api` only.

If a port conflict or custom port is needed, delegate to `/set-port` to configure both packages, then restart the affected server(s).

### 3. Login (full UI mode only)

Navigate to `http://localhost:3000/` and log in with:

- **Org**: from the work item's `Custom.Org` field, or `manual` as default.
- **Email**: `sahar.rachamim@fundguard.com`.

### 4. Execute repro steps

- **Full UI mode**: follow the provided reproduction steps in the browser using `cursor-ide-browser` MCP tools. Take screenshots at each significant step. If reference screenshots were provided (e.g. from a work item attachment), compare the observed state against them.
- **API-only mode**: send the relevant GraphQL queries or mutations directly to gql-api and inspect responses.

#### Error tracing

When the webapp displays an error originating from gql-api (typically containing a trace ID or error ID), look up that ID in the gql-api terminal output to get the full error details, stack trace, and context. This often reveals the root cause faster than inspecting the UI alone.

### 5. Report

Present findings to the calling command or user:

- **Reproduced / not reproduced**: clear verdict.
- **Evidence**: screenshots (full UI) or response payloads (API-only).
- **Trace/error IDs**: any IDs surfaced during reproduction.
- **Observations**: deviations from expected behaviour, additional symptoms discovered.

## Port configuration

By default, no port configuration is needed. If a custom port is required (e.g. conflict with another running instance), delegate to `/set-port` which sets `PORT` on `@fg/gql-api` and `FG_GQL_API_URL` on `@fg/webapp` in a single step.