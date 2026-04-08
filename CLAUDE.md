# CLAUDE.md — Permanent Project Brain

> **Layer 1 of 3** in the memory architecture. Never-forget rules only.
>
> - **CLAUDE.md** (this file) — never-forget rules, roster, conventions
> - **MEMORY.md** — pointer index of technical decisions and debugging patterns (auto-updated)
> - **.claude/rules/*.md** — modular, loaded only when relevant files are touched
> - **.claude/settings.json** — Claude Code runtime config (default main-thread agent, permission guardrails)

## Portable Project Agent Pack

This project ships a self-contained, portable multi-agent system. All agents live in `.claude/agents/` with `memory: project` — **they only learn from this project**. Context never leaks to other projects. The repo also sets `orchestrator` as the default **main-thread** agent in `.claude/settings.json` so orchestration happens in the session that can actually delegate.

### Roster

| Agent | Model | Role | Tool Silo |
|---|---|---|---|
| `orchestrator` | **opus** | Lead — decomposes goals, spawns specialists in parallel via `Agent` tool | `Agent`, `TodoWrite`, `Read`, `Grep`, `Glob` |
| `architect` | **opus** | Strategic design, tradeoff analysis (read-only) | `Read`, `Grep`, `Glob` |
| `reviewer` | **opus** | Two-stage review gate, severity-rated findings (read-only) | `Read`, `Grep`, `Glob` |
| `planner` | sonnet | 3–6 step decomposition with acceptance criteria (read-only) | `Read`, `Grep`, `Glob`, `TodoWrite` |
| `explorer` | haiku | Cross-validated codebase search (read-only) | `Read`, `Grep`, `Glob` |
| `coder` | sonnet | **Coding Agent** — minimal-diff implementation | `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `TodoWrite` |
| `debugger` | sonnet | Root-cause analysis, one hypothesis at a time | `Read`, `Edit`, `Bash`, `Grep`, `Glob` |
| `test-engineer` | sonnet | TDD, coverage, flaky-test triage | `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob` |
| `photo` | sonnet | **Photo Agent** — image processing via ImageMagick MCP | `Read`, `Write`, `Bash`, `mcp__imagemagick__*` |
| `researcher` | sonnet | **Research Agent** — web search + browser automation | `WebSearch`, `WebFetch`, `Read`, `Write`, `mcp__browser__*` |

### Never-Forget Rules (THIS PROJECT)

1. **Project isolation.** All agents use `memory: project`. They keep context and memory project-scoped, never consult user-global memory, and work only inside the current repo plus task-approved output folders such as `./research/` or `./output/`.
2. **Orchestrator is the default entry point** for any non-trivial task. `.claude/settings.json` makes it the main-thread agent so it can spawn specialists in **parallel** using the `Agent` tool whenever subtasks are independent.
3. **Explore before you act** on any task touching 3+ files.
4. **Never self-approve.** The agent that writes code never reviews it. `reviewer` gates every non-trivial implementation.
5. **Circuit breaker: 3 failures → escalate to `architect`.** No infinite loops.
6. **Fresh evidence only.** "Should work" is not acceptance. Show actual output.
7. **Prompt caching is mandatory** (see below).
8. **Adaptive thinking everywhere.** Every agent declares `thinking: {type: "adaptive"}` — shallow for trivia, deep for enterprise work.
9. **MEMORY.md is the pointer index.** Every technical decision, every non-obvious debugging insight, every gotcha gets a one-line entry before the task is closed.
10. **Modular rules are load-on-demand.** `.claude/rules/testing.md` loads when touching tests; `.claude/rules/ui-style.md` when touching UI; etc. Do not preload.
11. **Claude should not waste context on generated noise.** `.claude/settings.json` denies secrets and blocks common high-noise caches such as `node_modules`, virtualenv caches, `.cache`, `.turbo`, and `.DS_Store` files. Task-relevant build or coverage artifacts stay available when they are explicitly needed.
12. **Scope before search.** Agents start with the files, directories, errors, symbols, imports, callers, and tests most directly connected to the task. They only widen scope when the local evidence is insufficient, and they should say when they had to broaden the search.
13. **Task-local handoff packets beat per-agent memory files.** Agent responsibility lives in the prompt, project facts live in `MEMORY.md`, and task-specific context is passed as a compact handoff packet for the current task only.

## Prompt Caching Discipline (Cost Optimization)

Claude API prompt caching reduces input token cost by **up to 90%** on repeated reads within a session. All agents in this pack MUST follow these rules:

1. **Batch file reads in a single turn.** Read every file the task needs up front, in one tool-call batch, so the cached prefix covers the full context.
2. **Re-read the same file from the same agent.** Cache hits only happen when the prefix is byte-identical. Stable ordering of reads is critical.
3. **Never paraphrase file contents back into a prompt.** Just reference the file by path — the cached read is already in context.
4. **Prefer `Read` over `Bash cat`.** The Read tool is cache-aware; `cat` re-enters content as stdout and defeats caching.
5. **For long-horizon sessions**, the orchestrator should reuse the same explorer sub-agent across related sub-tasks so its context is cached rather than rebuilt.
6. **Do not shuffle tool calls.** Deterministic tool order = deterministic cache prefix = cheap re-use.

## Adaptive Thinking

All agents use `thinking: {type: "adaptive"}`. This means:

- Trivial tasks (single-file edits, lookups, one-shot commands) get shallow reasoning — fast and cheap.
- Complex tasks (multi-file refactors, architecture decisions, multi-week enterprise work) get deep extended thinking.
- Agents do not burn tokens reasoning about easy problems.

## Workflow: Huddle → Work → Debrief

For any task involving 2+ agents:

1. **Huddle** — orchestrator calls each needed agent with `HUDDLE_MODE: [task]`, then redistributes a shared Huddle Brief so the agents can critique each other's assumptions and strengthen the plan before work begins.
2. **Work** — orchestrator dispatches the real tasks **in parallel** (single message, multiple `Agent` tool calls) wherever possible, and each dispatch includes a compact handoff packet with only the context that agent actually needs.
3. **Debrief** — after completion, orchestrator calls each participant with `DEBRIEF_MODE: [summary]` plus relevant peer outputs so the team can review each other's work, surface missed risks, and record `LESSON_LEARNED` entries in `.claude/rules/LESSONS.md`. Keep huddles and debriefs concise: short bullet briefs, not long transcripts. One-line technical decisions flow into `MEMORY.md`.

## Project-Specific Stack & Conventions

*(Fill in when the project stack is known: language, framework, test runner, deployment target.)*
