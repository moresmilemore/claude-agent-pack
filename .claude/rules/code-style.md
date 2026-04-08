---
scope: coder, debugger, test-engineer
load_when: any source file is being modified
---

# Code Style Rules

## General Principles

- **Match surrounding code.** Tabs or spaces, snake_case or camelCase, import order — match what's there. Do not impose preferences.
- **No style imposition on unrelated code.** Reformatting unchanged lines is scope creep.
- **Smallest diff wins.** Prefer a 3-line fix to a 30-line "cleanup".

## Naming

- Variables/functions: `camelCase` (JS/TS) or `snake_case` (Python) — match project
- Classes/types: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Test files: match existing pattern (`*.test.ts`, `*_test.py`, etc.)

## Imports

- Order: stdlib → third-party → first-party → relative
- One blank line between groups
- Never mass-reorder imports in files you didn't otherwise change

## Error Handling

- Never swallow exceptions silently — log with context at minimum
- Error messages: what failed + what was expected + what to do
- Typed errors over stringly-typed errors
- No bare `except:` or `catch (e) {}`

## Comments

- Comments explain **why**, not **what**
- Update comments when you change the code
- Delete dead code — git preserves history

## Formatting

- Defer to the project's formatter (prettier, black, gofmt)
- Never hand-format
