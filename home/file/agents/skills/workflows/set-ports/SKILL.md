---
name: set-ports
description: Resolves and sets ports for @fg/gql-api and @fg/webapp, keeping both .env files in sync. Auto-detects port conflicts across worktrees and picks available ports when defaults (8080, 3000) are in use. Use when configuring local development ports so both services start without conflicts.
disable-model-invocation: true
---

# Set Ports

Resolve and set ports for `@fg/gql-api` and `@fg/webapp`, keeping both `.env` files in sync. Supports running multiple worktrees simultaneously by auto-detecting port conflicts and picking available alternatives.

## Input

Accept optional **port numbers** for one or both services:

- **gql-api port** (e.g. `4001`)
- **webapp port** (e.g. `3001`)

If a single port number is provided without specifying which service, treat it as the gql-api port (backwards-compatible with the former `/set-port` skill).

## Steps

### 1. Resolve ports

For each service (gql-api and webapp), resolve the port using this priority:

1. **Explicit input** -- if the user provided a port for this service, use it.
2. **Existing `.env` value** -- if the service's `.env` file already contains a `PORT=` line, reuse that value.
3. **Auto-detect from default** -- try the default port (8080 for gql-api, 3000 for webapp). Check availability via `lsof -iTCP:<port> -sTCP:LISTEN`. If the default is in use, increment until an available port is found.

### 2. Set PORT on gql-api

Locate `packages/apps/gql-api/.env` relative to the workspace root (the workspace is expected to be the `client` directory of an fgrepo worktree). If the file already contains a `PORT=` line, replace the value. Otherwise, append the line.

Set:

```
PORT=<gql-api-port>
```

### 3. Set PORT and FG_GQL_API_URL on webapp

Locate `packages/apps/webapp/.env` relative to the workspace root. For each variable, if the file already contains a matching line, replace the value. Otherwise, append the line.

Set:

```
PORT=<webapp-port>
FG_GQL_API_URL=http://localhost:<gql-api-port>/fg-gql
```

### 4. Confirm

Display to the user:

```
## Ports Updated

| Service | Port | .env file |
|---------|------|-----------|
| **gql-api** | <gql-api-port> | <absolute path to gql-api .env> |
| **webapp** | <webapp-port> | <absolute path to webapp .env> |
```

### 5. Evolve

Follow the **continuous-improvement** skill.
