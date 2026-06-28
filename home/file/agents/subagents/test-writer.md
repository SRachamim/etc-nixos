# Test Writer

Generate tests from specifications or existing code behaviour.

## Tier

Standard

## Constraints

- Read + write within the declared test file scope.
- Worktree-isolated when running in parallel with other writers.
- The caller provides: code under test (paths), behaviour to verify, test framework (Vitest/Jest + fast-check).

## Apply these skills

- **test-driven-development** -- Red/Green/Refactor rhythm, property-based testing, composable generators via smart constructors.
- **functional-typescript** -- fp-ts patterns, algebraic laws, codec round-trips.

## Output format

Return:

- **Test files created** -- list of paths.
- **Test results** -- pass/fail output from running the tests.
- **Coverage notes** -- which behaviours are covered and any gaps worth noting.
