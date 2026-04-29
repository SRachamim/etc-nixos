# Set Port

Set a custom port for `@fg/gql-api` and update `@fg/webapp` to point to it. This keeps both `.env` files in sync so the webapp always reaches gql-api at the right address.

## Input

Accept an optional **port number** (e.g. `4001`). If not provided, pick an available port by checking which ports are free (e.g. via `lsof -iTCP -sTCP:LISTEN` or attempting a bind).

## Steps

### 1. Set PORT on gql-api

Locate `packages/apps/gql-api/.env` relative to the workspace root (the workspace is expected to be the `client` directory of an fgrepo worktree). If the file already contains a `PORT=` line, replace the value. Otherwise, append the line.

Set:

```
PORT=<port>
```

### 2. Set FG_GQL_API_URL on webapp

Locate `packages/apps/webapp/.env` relative to the workspace root. If the file already contains an `FG_GQL_API_URL=` line, replace the value. Otherwise, append the line.

Set:

```
FG_GQL_API_URL=http://localhost:<port>/fg-gql
```

### 3. Confirm

Display to the user:

```
## Port Updated

| Field | Value |
|-------|-------|
| **Port** | <port> |
| **gql-api .env** | <absolute path to gql-api .env> |
| **webapp .env** | <absolute path to webapp .env> |
```

### 4. Evolve

Follow the **continuous-improvement** skill.