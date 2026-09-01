---
name: mcp-namespace-priority-g
description: Prefer native (first-party) MCP namespaces over proxy/aggregator MCPs when both offer overlapping functionality. Apply whenever selecting an MCP tool for ADO, Slack, or any domain where a native and a proxy namespace coexist.
---

# MCP Namespace Selection Priority

When multiple MCP namespaces can perform the same operation, prefer the **native** (first-party) namespace. Proxy/aggregator namespaces exist to provide composite tools and sensible defaults, but they add an intermediary layer that can lose identity context, miss native-only capabilities, or introduce routing failures.

## Priority table

| Domain | Preferred (native) | Fallback (proxy) |
|--------|---------------------|-------------------|
| Azure DevOps | `user-Azure DevOps` | `user-fundguard` |
| Slack | `user-Slack` | -- (no proxy equivalent) |

Extend this table when new native/proxy pairs appear.

## Decision procedure

1. **Identify the operation** -- what ADO/Slack action is needed?
2. **Discover the native tool** -- run `GetDynamicTools` (or equivalent) against the native namespace to check whether it exposes a tool that covers the operation. If yes, use it.
3. **Fall back to proxy** -- if the native MCP has no equivalent, use the proxy. The FundGuard proxy provides composite and value-add tools not available natively.

Do not skip step 2. The proxy's convenience (e.g. sensible defaults for `org`, `project`, `repoId`) does not justify bypassing the native MCP when it has the tool. When the native tool requires explicit parameters that the proxy defaults, supply them.

## Notable native-only operations

These are examples of operations only available through the native MCP -- the proxy cannot perform them:

- **PR voting and reviewer management** -- casting votes, adding/removing reviewers
- **Identity resolution** -- resolving user identities by name or email
- **Sprint/iteration management** -- iterations, capacity, team settings
- **Test plans** -- test plan and test case CRUD
- **Full-text code search** -- searching code across repos
- **Advanced security** -- security alert management
- **Branch and repo browsing** -- creating branches, listing directories, reading file content

This is not exhaustive. Always discover the native namespace at runtime to find the current tool set.

## When to use the proxy

The proxy provides composite tools that aggregate multiple API calls or enrich data from additional sources (Datadog, Currents, Sunday). Use the proxy for:

- Build failure analysis with observability enrichment
- One-shot PR review context (details + diffs + threads + work items)
- Batch diffs with glob filtering and iteration comparison
- Batch posting of review findings
- Cross-domain tools (Datadog, Currents, Sunday, DevTools)

## Slack: always native

The FundGuard proxy has no Slack tools. All Slack operations use `user-Slack` exclusively.
