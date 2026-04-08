---
scope: test-engineer, coder, debugger
load_when: files matching **/*.test.*, **/*.spec.*, **/test_*.py, **/tests/**, or any test framework config
---

# Testing Rules

## Pyramid

- **70% unit** — fast, isolated, deterministic
- **20% integration** — real dependencies where cheap
- **10% e2e** — critical user paths only

Do not write e2e tests for things unit tests cover.

## Naming & Structure

- **One test = one behavior.** No combined assertions across concerns.
- **Test names describe behavior**: `it should return 404 when user not found` — never `test case 3`.
- **Arrange / Act / Assert** structure in every test.

## Mocking Discipline

- Mock **external** dependencies (network, filesystem, clock, random).
- Do NOT mock internal logic. If you must mock your own code to test it, refactor instead.
- Over-mocking tests your mocks, not your code.

## Flaky Test Root Causes

1. Timing — `setTimeout`, `Promise` ordering, races
2. Shared state — globals, database, filesystem, module caches
3. Hardcoded dates / timezones / locales
4. Non-deterministic ordering
5. Port collisions, environment paths

**`retry(3)` is not a fix.** Find the root cause.

## Fixtures

- Match the existing framework's fixture pattern.
- Teardown must be symmetric with setup.
- Prefer factory functions over shared mutable fixtures.

## Coverage Priorities

1. Critical paths (auth, payments, data mutation) — always
2. Edge cases and error conditions
3. Happy path (usually already works)
