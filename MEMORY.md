# MEMORY.md — Project Pointer Index

> **Layer 2 of 3** in the memory architecture. This is the project's shared long-term memory.
>
> Agents propose entries for this file when they discover durable project knowledge, but the **orchestrator** appends them only after the underlying work is verified complete. Keep entries to **one line each** — this is a pointer index, not a design doc. Link out to files/PRs/rules for detail.
>
> **Format:** `[YYYY-MM-DD] [agent] [TYPE] — [one-line insight] → [optional pointer]`
>
> **Types:** `DECISION` · `BUGFIX` · `QUIRK` · `PATTERN` · `ANTI-PATTERN`

## Technical Decisions

*(Architecture choices, library selections, pattern adoptions, deliberate constraints.)*

<!-- Example:
[2026-04-06] architect DECISION — Chose Zustand over Redux for auth state → see PR #42
[2026-04-06] coder DECISION — All timestamps stored as UTC epoch ms; display-layer converts → src/utils/time.ts
-->

## Debugging Patterns

*(Where bugs tend to hide in this codebase. What symptoms map to which root causes.)*

<!-- Example:
[2026-04-06] debugger BUGFIX — /api/session 401s are cookie domain mismatches, not token expiry → src/auth/cookies.ts:34
[2026-04-06] debugger QUIRK — The test DB resets between suites but NOT between tests in the same file
-->

## Codebase Quirks

*(Surprising conventions, hidden dependencies, undocumented patterns that will bite future agents.)*

## Patterns That Work

*(Reusable utilities, established approaches worth copying.)*

## Anti-Patterns (Proven Bad in This Repo)

*(Approaches that have been tried and failed — do not re-attempt without new information.)*
