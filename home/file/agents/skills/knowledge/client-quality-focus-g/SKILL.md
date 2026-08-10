---
name: client-quality-focus-g
description: Non-functional requirements concentration for the FundGuard client monorepo. Loaded whenever the agent works in fgrepo client/ -- biases all activities (planning, implementing, reviewing, testing, debugging) toward quality attributes. Use whenever the agent operates on code under the fgrepo client directory.
---

# Client Quality Focus

Concentrate on non-functional requirements when working in the FundGuard client monorepo. This skill biases agent attention toward quality attributes across all activities -- it does not replace functional reasoning but ensures NFRs receive proportional weight in every decision.

The framing follows the SEI Quality Attribute Workshop principle: every change should be evaluated against quality attribute scenarios. A quality attribute scenario has a stimulus (what happens), an environment (under what conditions), and a response measure (what "good" looks like). When planning, implementing, or reviewing, ask: "which quality attributes does this change stress, and does it meet or degrade the response measure?"

## Detection

This skill applies when working in the FundGuard client monorepo, identified by any of:

- The workspace path contains `client/` alongside sibling directories like `devops/`, `automation/`, or `backend/`.
- The git remote URL contains `fgrepo`.
- The pnpm workspace name is `fg` with `@fg/*` scoped packages.

## Quality Attributes

Adapted from ISO/IEC 25010:2023, filtered and prioritized for a React/Apollo/fp-ts/Webpack pnpm monorepo with a GraphQL BFF.

### Performance Efficiency

| Concern | Concrete guidance |
|---------|-------------------|
| Bundle size | Enforce per-chunk budgets. Use dynamic `import()` for route-level code splitting. Audit new dependencies for tree-shakeability. |
| Render performance | Minimize re-renders: memoize expensive computations, lift state to the narrowest necessary scope, avoid inline object/function creation in render paths. |
| Virtualization | Large lists and tables must use `react-window` or equivalent. Never render unbounded DOM node counts. |
| Apollo cache efficiency | Respect the dual-client pattern -- App Shell client for stable reference data, Route client for entity CRUD. Avoid cache pollution across boundaries. |
| Core Web Vitals | LCP, FID/INP, CLS targets inform component loading strategy. Prefer skeleton UIs over spinners for layout stability. |
| Lazy loading | Route containers and heavy libraries (Highcharts, date-fns locales) should be lazily imported. |
| Webpack chunks | Shared vendor chunks for stable dependencies; route-specific chunks for feature code. Monitor chunk count and total size in CI. |

### Maintainability

| Concern | Concrete guidance |
|---------|-------------------|
| fp-ts purity | Functions must be pure. Side effects pushed to boundaries via `TaskEither`, `IO`, or `ReaderTaskEither`. `eslint-plugin-functional` enforces no-mutations and no-exceptions. |
| Type-driven modeling | Domain types use branded newtypes, discriminated unions, and smart constructors. Make illegal states unrepresentable. |
| Module boundaries | Respect `@fg/*` package boundaries. Cross-package imports go through public barrel exports. No reaching into internal paths. |
| Dead code | `ts-prune` detects unused exports. Remove dead code in the same PR that makes it dead. |
| Test coverage | Libraries enforce 100% coverage thresholds. Webapp coverage should not regress. |
| Lint compliance | `eslint-plugin-fp-ts`, `@typescript-eslint/strict`, `sonarjs`, and `@fg/eslint-plugin-fundguard` rules are non-negotiable. |

### Reliability

| Concern | Concrete guidance |
|---------|-------------------|
| Error handling | Use `Either`/`Option` instead of thrown exceptions. `TaskEither` for async operations. Exhaustive pattern matching on error variants. |
| Error boundaries | React error boundaries at route level prevent full-app crashes. |
| Apollo error policies | Set appropriate `errorPolicy` per query. Distinguish network errors from GraphQL errors. Handle partial data gracefully. |
| Subscription reconnection | GraphQL subscriptions (`graphql-ws`, `graphql-sse`) must handle reconnection, backoff, and stale-data indicators. |
| Graceful degradation | Features behind `@fg/feature-bits` toggles must degrade cleanly when disabled. |

### Security

| Concern | Concrete guidance |
|---------|-------------------|
| XSS prevention | Never use `dangerouslySetInnerHTML`. Sanitize any user-provided content rendered as HTML. |
| CSP compatibility | No inline scripts or styles that break Content-Security-Policy. Styled-components uses nonces or hashes. |
| Auth tokens | Tokens stay in httpOnly cookies or secure session storage. Never expose tokens in URLs, localStorage, or client-side logs. |
| Input validation | Validate external data (API responses, URL params, user input) at system boundaries using io-ts codecs. Do not trust runtime values without decoding. |
| Dependency scanning | New dependencies must be evaluated for known vulnerabilities. Prefer well-maintained packages with narrow scope. |
| CORS | BFF endpoints enforce restrictive CORS. Frontend never circumvents CORS by proxying through unexpected paths. |

### Accessibility

| Concern | Concrete guidance |
|---------|-------------------|
| WCAG 2.2 AA baseline | All new UI must meet WCAG 2.2 Level AA. This is non-negotiable for interactive components. |
| jsx-a11y enforcement | ESLint `jsx-a11y` plugin rules are blocking errors, not warnings. |
| Keyboard navigation | Every interactive element must be reachable and operable via keyboard. Custom widgets need explicit `tabIndex`, `onKeyDown` handlers. |
| Focus management | Route transitions, modal opens, and dynamic content insertions must manage focus programmatically. |
| Screen reader support | Meaningful `aria-label`, `aria-describedby`, `role` attributes. Live regions (`aria-live`) for dynamic updates. |
| Semantic HTML | Prefer native elements (`button`, `a`, `input`) over `div` with click handlers. |
| Stylelint a11y | `stylelint-a11y` plugin catches contrast and motion-preference issues in stylesheets. |

### Observability

| Concern | Concrete guidance |
|---------|-------------------|
| Datadog RUM | Browser performance metrics, user actions, and errors flow to Datadog. New features should emit custom RUM actions for key user journeys. |
| Structured logging | Client-side logs use structured format via the global logger. Include correlation IDs for request tracing. |
| OpenTelemetry | gql-api traces propagate context headers. Frontend Apollo link attaches trace context to GraphQL requests. |
| Error tracking | Unhandled errors and rejected promises must be captured with sufficient context (user, route, feature flags). |
| Performance marks | Critical user flows emit `performance.mark()` / `performance.measure()` for lab and field measurement. |

### Usability

| Concern | Concrete guidance |
|---------|-------------------|
| i18n completeness | All user-visible strings go through `react-intl`. No hardcoded English in components. |
| Loading states | Every async operation handles all states: idle, loading, success, empty, error, stale, partial. Skeleton UIs for layout stability. |
| Responsive design | Components adapt to viewport. Tables use horizontal scroll or responsive layouts. No content overflow. |
| Component consistency | Prefer Mantine/Shoelace components from `@fg/components` over ad-hoc implementations. |

## Activity-Specific Concentration

### Planning and PRD intake

- For every functional requirement, ask: "which quality attributes does this feature stress?"
- Identify NFR implications explicitly -- a feature adding a new data table implies virtualization, accessibility, and loading-state requirements.
- Flag requirements that create tension between quality attributes (e.g., rich real-time updates vs. performance efficiency) and propose resolution strategies.
- Include NFR acceptance criteria in task definitions: response time targets, accessibility level, security constraints.

### Implementation

- Apply performance patterns by default: memoize derived data, virtualize long lists, lazy-load heavy routes.
- Maintain type-safety invariants: smart constructors, branded types, exhaustive matching.
- Ensure accessibility of every new interactive element before considering the implementation complete.
- Validate external data at boundaries with io-ts codecs.
- Emit observability signals (RUM actions, performance marks) for new user journeys.

### Testing

- Property-based tests (fast-check) for domain invariants and codec round-trips.
- Accessibility checks in component tests (Testing Library queries prefer accessible selectors: `getByRole`, `getByLabelText`).
- Performance assertions where measurable (no N+1 re-renders, bundle size thresholds in CI).
- Security-relevant tests: validate that io-ts codecs reject malformed input, that auth guards prevent unauthorized access.

### Code review

- Weight NFR dimensions (performance, security, accessibility) higher than style preferences. An accessibility regression is a blocking finding; a naming nit is a suggestion.
- Flag missing error handling, unvalidated external data, and accessibility gaps as blocking issues.
- Evaluate whether new dependencies justify their bundle size impact.
- Check that Apollo queries use appropriate fetch policies and error policies.

### Debugging

- Consider whether the bug is an NFR violation: performance degradation, accessibility regression, security exposure, observability gap.
- When diagnosing performance issues, check for: unnecessary re-renders, missing virtualization, cache misses in Apollo, unbounded DOM growth, missing code splitting.
- When diagnosing errors, check for: missing Either/Option handling, untyped catch blocks, missing error boundaries.

### Research and evaluation

- When evaluating libraries or patterns, weight NFR impact alongside functionality: bundle size, tree-shakeability, accessibility support, TypeScript type quality, maintenance status.
- Prefer solutions that improve multiple quality attributes simultaneously over point solutions.
- Apply the **architect-thinking-g** skill's Options Thinking: prefer reversible choices that don't lock out future NFR improvements.

## Codebase-Specific Patterns

### Apollo dual-client architecture

- **App Shell client**: session-lifetime cache for reference/static data (enums, configurations, user permissions). Cache here is rarely invalidated.
- **Route client**: per-route cache for entity CRUD. Reset on navigation. Mutations refetch or update the Route client cache, not the App Shell client.
- **Performance implication**: avoid queries that span both clients. Route client eviction on navigation prevents stale data at the cost of refetching -- monitor refetch frequency.

### fp-ts pipe chains

- Long pipe chains with many intermediate allocations are acceptable when clarity wins -- but watch for hot paths where object creation matters.
- Prefer `flow` over `pipe` for point-free function composition that avoids intermediate closures.
- Use `sequenceT` / `sequenceS` for parallel validation rather than nested `chain` calls.

### Webpack and bundle strategy

- Route containers use dynamic `import()` with `webpackChunkName` annotations.
- Shared vendor chunk for: React, Apollo, fp-ts, styled-components.
- Per-route feature chunks for: Highcharts, heavy form schemas, specialized views.
- Monitor total bundle size in CI; regressions require justification.

### Styled-components

- Prefer static styled components (defined outside render) over dynamic ones for reduced runtime cost.
- Use `css` prop or theme tokens for conditional styling rather than creating new styled wrappers per variant.
- Evaluate CSS-in-JS overhead for performance-critical render paths.

### React-table and react-window

- Tables with more than ~50 rows must virtualize. `react-window` integration with `react-table` is the established pattern.
- Column definitions should be memoized. Avoid recreating column configs on every render.

### GraphQL patterns

- Colocate fragments with the components that consume them.
- Monitor query complexity -- deeply nested or widely joined queries stress the BFF and increase response time.
- Subscriptions have lifecycle costs: connect, reconnect, teardown. Ensure components unsubscribe on unmount.

### io-ts boundary validation

- Every external data source (GraphQL responses, URL parameters, localStorage reads, postMessage payloads) passes through an io-ts codec before entering domain logic.
- Codecs are the security and reliability boundary: they reject invalid shapes before bad data propagates.
- Use `pipe` with `fold` to handle decode failures explicitly -- never ignore decode errors silently.

## Relationship to Other Skills

- **functional-typescript-g** -- provides the maintainability foundation through type-driven design, purity, and algebraic modeling. This skill adds the concentration on *why* those patterns matter as NFR enablers.
- **architect-thinking-g** -- Options Thinking preserves future NFR improvements; Rate of Change ensures the architecture supports evolving quality targets. This skill concretizes those principles for the client codebase.
- **code-review-g** -- the review skill's Performance, Security, and Flexibility dimensions are weighted higher when this skill is active. Accessibility is elevated to a blocking dimension.
- **test-driven-development-g** -- property-based testing with fast-check directly serves the Reliability and Maintainability attributes.
- **building-microservices-g** -- the Resiliency patterns (circuit breakers, bulkheads, timeouts) apply to the gql-api layer's interactions with downstream services.
