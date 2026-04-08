# Custom Claude Code Agent Pack

This repository is a portable multi-agent operating system for Claude Code.

It is not a traditional app or library. It is a packaged team of custom agents, shared rules, memory files, and MCP integrations that you can drop into a project so Claude Code behaves more like a disciplined engineering team than a single generalist assistant.

## Downloadable Bundle

If you want the drop-in package instead of the raw repo contents, use:

- `claude-agent-pack-2026-04-07.zip`

That archive is intended to be copied into a target project root, unzipped, and then activated with `./install.sh`.

## Audit Status

This repo has a dedicated audit report in `AUDIT.md`.

Current audit summary:

- the pack is structurally sound
- the orchestrator is correctly configured as the main-thread lead
- specialists now work from scoped handoff packets instead of per-agent memory files
- memory ownership is explicit: specialists propose entries, orchestrator commits them after verification
- runtime settings block noise and secrets without blocking legitimate build or coverage inspection

## What Is Actually Custom Here

Claude Code provides the runtime, but the operating model in this repo is custom.

The most distinctive original pieces are:

- the strict `orchestrator`-first delegation model
- the `HANDOFF_PACKET` system for scoped task-local context
- the shared `CLAUDE.md` + `MEMORY.md` + `LESSONS.md` memory architecture
- the huddle -> work -> debrief collaboration flow
- the scope-first, token-efficiency rules across the specialists

If you want to show someone how your setup works, the short version is:

- `orchestrator` acts like the team lead
- specialists handle planning, search, coding, debugging, testing, review, research, and image work
- shared rules keep behavior consistent
- a layered memory system preserves useful project knowledge without leaking across projects
- an installer validates the pack and checks the MCP prerequisites

## What This Project Actually Is

This folder contains a self-contained agent pack designed for Claude Code's project-level agent system.

The pack defines:

- 10 custom agents in `.claude/agents/`
- shared runtime settings in `.claude/settings.json`
- shared rules in `.claude/rules/`
- a 3-layer memory model using `CLAUDE.md`, `MEMORY.md`, and modular rules
- MCP server definitions in `.mcp.json`
- an installer/validator in `install.sh`

The overall goal is to make Claude Code work with stronger separation of responsibilities:

- planning is different from coding
- coding is different from debugging
- implementation is different from review
- external research and image processing are isolated behind dedicated agents and tools

That separation is the main design idea in this repo.

## Core Design Philosophy

The pack is built around five ideas.

### 1. Strict Delegation

The `orchestrator` is intentionally forbidden from doing implementation work itself. Its job is to:

1. understand the request
2. break it into subtasks
3. assign the right specialist
4. run independent work in parallel
5. collect results and report back

That matters because it prevents the "manager prompt that also codes, reviews, researches, and debugs" problem. Instead of one overloaded agent improvising everything, the system pushes work to role-specific prompts with role-specific tool access.

### 2. Tool Silos

Each agent only gets the tools it should need.

- read-only agents like `architect`, `reviewer`, and `explorer` cannot edit code
- `coder` and `test-engineer` can edit and run shell commands
- `photo` is isolated to image tooling
- `researcher` is isolated to web and browser tooling

This reduces accidental misuse and makes each agent prompt easier to reason about.

### 3. Memory With Boundaries

The pack uses `memory: project` on every agent, so the memory stays inside the current project instead of blending across repos.

The memory model is split into three layers:

- `CLAUDE.md`: permanent operating rules, roster, conventions
- `MEMORY.md`: append-only pointer index for technical decisions, bug patterns, quirks, and lessons worth reusing
- `.claude/rules/*.md`: specialized guidance loaded only when relevant

This is one of the strongest parts of the design. It keeps persistent guidance short, scoped, and useful.

### 4. Evidence Over Vibes

The prompts repeatedly enforce:

- cite files and lines
- verify with actual output
- do not say "should work"
- do not self-approve
- escalate after repeated failures instead of looping forever

This gives the whole pack a more auditable feel than a normal free-form assistant workflow.

### 5. Prompt Caching Discipline

A surprising amount of the prompt design is about cost and repeatability.

Multiple agents explicitly instruct themselves to:

- batch file reads up front
- keep read order stable
- avoid paraphrasing large file contents back into prompts
- prefer native read tools over shell dumps

So this repo is not just about agent roles. It is also about making long Claude Code sessions cheaper and more consistent.

## Repository Structure

```text
.
├── CLAUDE.md
├── MEMORY.md
├── README.md
├── install.sh
├── .mcp.json
└── .claude/
    ├── agents/
    │   ├── orchestrator.md
    │   ├── architect.md
    │   ├── reviewer.md
    │   ├── planner.md
    │   ├── explorer.md
    │   ├── coder.md
    │   ├── debugger.md
    │   ├── test-engineer.md
    │   ├── photo.md
    │   └── researcher.md
    ├── settings.json
    └── rules/
        ├── code-style.md
        ├── testing.md
        ├── ui-style.md
        ├── security.md
        └── LESSONS.md
```

## How The System Works

### The Main Entry Point: `orchestrator`

The `orchestrator` is the traffic controller for non-trivial work.

The pack now wires this correctly through `.claude/settings.json`, which sets `orchestrator` as the default main-thread agent. That is an important compatibility fix for Claude Code, because the orchestration prompt is designed to delegate and monitor work rather than behave like a normal delegated specialist.

Its prompt is unusually strict:

- it must not write code
- it must not run builds or tests
- it must not do review, debugging, image work, or research itself
- it should use the `Agent` tool as its primary mechanism
- it should batch independent work in parallel

In other words, this pack treats orchestration as a real job, not a decorative title.

The orchestrator workflow is:

1. Understand the goal.
2. Decompose it into concrete subtasks.
3. Run a real huddle where agents propose plans, then critique each other's assumptions through a shared huddle brief.
4. Dispatch specialists, ideally in parallel.
5. Monitor progress and handle escalations.
6. Run a peer-aware debrief so agents review each other's outputs and capture lessons.
7. Write verified lessons back into memory.

### The Specialist Agents

Each specialist is opinionated and intentionally narrow.

| Agent | Purpose | What It Owns |
|---|---|---|
| `orchestrator` | Team lead | delegation, sequencing, synthesis |
| `architect` | System design specialist | tradeoffs, structure, escalations after repeated failure |
| `reviewer` | Quality gate | spec compliance, correctness, security, verdicts |
| `planner` | Decomposition specialist | 3-6 step execution plans with acceptance criteria |
| `explorer` | Codebase mapper | finding files, callers, dependencies, tests |
| `coder` | Implementation specialist | minimal-diff code changes, verification |
| `debugger` | Bug fixer | reproduction, root cause analysis, minimal fixes |
| `test-engineer` | Testing specialist | TDD, coverage, flaky test diagnosis |
| `photo` | Image specialist | ImageMagick-backed transforms and asset work |
| `researcher` | External info specialist | docs, release notes, web research, browser automation |

## Agent-by-Agent Breakdown

### `orchestrator`

This is the most important prompt in the pack. It enforces a six-phase operating model:

- Understand
- Decompose
- Team huddle
- Parallel dispatch
- Monitor and resolve
- Synthesize and commit memory

It also defines the system's strongest safety rails:

- no direct implementation
- no skipping review
- no serial execution when parallel work is possible
- no premature memory writes
- escalate to `architect` after 3 failed attempts on the same problem

This prompt is doing real governance, not just coordination.

It now also explicitly treats planning as a team activity: the specialists huddle before execution to strengthen the plan, and they debrief with peer context after execution to surface better ideas and missed risks.

### `architect`

The `architect` is a read-only strategy agent. It exists for decisions that need tradeoff analysis rather than immediate coding.

It is especially useful for:

- architectural changes
- complex refactors
- ambiguous design choices
- rescuing stuck implementation/debugging loops

Its outputs are structured around options, tradeoffs, and recommendations rather than code.

### `reviewer`

The `reviewer` acts as the merge gate. It performs:

1. Stage 1: spec compliance
2. Stage 2: code quality

That separation is smart. It means the agent first checks whether the change solved the right problem before getting distracted by style or implementation details.

This agent is where security review gets pulled in when needed through `.claude/rules/security.md`.

### `planner`

The `planner` is responsible for turning vague or multi-file work into a small set of verifiable steps.

Its job is not to brainstorm forever. Its prompt forces concise plans:

- 3 to 6 steps
- concrete acceptance criteria
- explicit dependencies
- stated risks

That makes it useful as a pre-implementation contract.

### `explorer`

The `explorer` is the mapmaker.

Before large changes, this agent is supposed to answer:

- where is the relevant code?
- who calls it?
- what does it depend on?
- where is it tested?
- what patterns already exist here?

Because it is read-only and cross-validates with multiple search strategies, it helps reduce blind edits.

### `coder`

The `coder` is the implementation workhorse. Its philosophy is minimalism:

- smallest possible diff
- match existing patterns
- avoid "while I'm here" changes
- verify after each non-trivial change

It is the agent most directly optimized for real code changes rather than explanation.

### `debugger`

The `debugger` is tightly scoped around root cause analysis. The prompt strongly emphasizes:

- reproduce first
- form one hypothesis at a time
- test that hypothesis
- reject it if it fails
- avoid speculative fixes

That makes it a good complement to `coder`, especially when the issue is diagnostic rather than additive.

### `test-engineer`

This agent focuses on test quality rather than just test quantity.

It pushes a few strong standards:

- one behavior per test
- descriptive test names
- testing pyramid discipline
- no `.skip`
- no lazy mocking of internal logic

This prompt would likely help keep generated tests cleaner than a default assistant pass.

### `photo`

This is a notable part of the pack because it extends beyond software engineering into asset work.

The `photo` agent is wired to ImageMagick MCP and is designed for:

- resizing
- conversion
- compositing
- watermarking
- metadata-aware batch transforms

It defaults to writing outputs into `./output/` and explicitly avoids overwriting originals unless asked.

### `researcher`

The `researcher` handles live external information and browser automation.

It is meant for:

- docs lookups
- release notes
- API references
- framework comparisons
- vulnerability research

Its prompt prefers official sources, requires citations, and encourages saving larger research outputs into `./research/`.

## Shared Rules

The `.claude/rules/` directory gives the specialists reusable guardrails.

### `code-style.md`

This file reinforces low-diff implementation behavior:

- match local style
- avoid formatting unrelated code
- prefer the project's formatter
- write comments for why, not what

### `testing.md`

This defines the expected testing approach:

- 70/20/10 pyramid
- one behavior per test
- Arrange / Act / Assert structure
- fix flaky roots, not symptoms

### `ui-style.md`

This is the UI-specific guidance:

- preserve the project's styling approach
- keep accessibility non-optional
- avoid weak component patterns
- prefer mobile-first responsive structure

### `security.md`

This is the high-signal risk rule file. It covers:

- secret handling
- input validation
- auth and authorization expectations
- dependency caution
- concrete review red flags

### `LESSONS.md`

This is separate from `MEMORY.md`.

The distinction appears to be:

- `MEMORY.md` stores repo-specific technical facts and decisions
- `LESSONS.md` stores cross-agent operational lessons from completed work

That split is useful because not every lesson is a permanent architectural fact.

## Memory Architecture

This repo has one of the clearest memory strategies you can give a coding assistant.

### Layer 1: `CLAUDE.md`

This is the permanent operating manual.

It defines:

- the roster
- the tool silos
- project-wide rules
- prompt-caching expectations
- the huddle/work/debrief model

If someone asks "what are the non-negotiables of this pack?", this is the answer.

### Layer 2: `MEMORY.md`

This is intentionally not a long knowledge base. It is a pointer index.

The required entry format keeps it short and useful:

`[date] [agent] [TYPE] — [insight] → [pointer]`

That helps future sessions reuse important decisions without turning memory into a giant wall of prose.

### Layer 3: Modular Rules

The rule files are effectively situational memory.

They are designed to load only when needed, which keeps context cleaner and avoids polluting every task with every rule.

## Runtime Settings

The repo-level `.claude/settings.json` now does two important jobs:

- sets `orchestrator` as the default main-thread agent
- denies access to secrets and blocks common high-noise caches like `node_modules`, virtualenv caches, `.cache`, `.turbo`, and `.DS_Store` files while still allowing task-relevant build or coverage artifacts when they actually matter

That improves both compatibility and efficiency. Claude spends less time searching junk, and the lead agent now runs in the Claude Code context that can actually coordinate the rest of the pack.

## MCP Integrations

The pack includes two MCP server definitions in `.mcp.json`.

### ImageMagick MCP

Used by `photo`.

- command: `uvx mcp-server-imagemagick`
- expected output directory: `./output`
- requires `uvx`
- requires ImageMagick 7+
- no longer hardcodes a single Homebrew `MAGICK_HOME` path, which makes the pack more portable across different machines

### Playwright MCP

Used by `researcher`.

- command: `npx -y @playwright/mcp@latest`
- headless by default
- browser timeout set to 30 seconds

Together these make the pack more than a prompt bundle. They give two specialists real capabilities beyond text editing.

## Installer Behavior

`install.sh` does more than print instructions. It acts as a validator for the pack.

It checks:

- required file layout
- JSON configuration validity
- agent frontmatter invariants
- ImageMagick availability
- `uvx` availability for the ImageMagick MCP launcher
- Node and `npx` availability
- optional installation via `brew`, `apt`, `dnf`, or `pacman`

So the install script is really a bootstrap + sanity-check tool, not just a convenience wrapper.

## Example Request Flows

### Example 1: Feature Work

User asks for a non-trivial feature.

Expected flow:

1. `orchestrator` receives the request
2. `planner` or `explorer` helps define scope
3. `coder` implements
4. `test-engineer` adds or validates tests
5. `reviewer` gates the result
6. `orchestrator` synthesizes the final answer
7. verified lessons get written to memory

### Example 2: Bug Fix

User reports a failing behavior.

Expected flow:

1. `orchestrator` routes to `debugger`
2. `debugger` reproduces and isolates root cause
3. `coder` or `debugger` applies the minimal fix
4. `test-engineer` confirms regression coverage if needed
5. `reviewer` checks the fix
6. memory gets updated only after verification

### Example 3: Docs or API Research

User asks about a library, version behavior, or current guidance.

Expected flow:

1. `orchestrator` routes to `researcher`
2. `researcher` gathers official sources and supporting references
3. findings are saved if the investigation is substantial
4. `architect` or `coder` consumes the research if implementation follows

### Example 4: Asset Work

User asks for image conversion or batch processing.

Expected flow:

1. `orchestrator` routes to `photo`
2. `photo` identifies source files first
3. it runs a defined transform pipeline
4. outputs land in `./output/`
5. originals stay untouched unless explicitly approved

## What This Pack Does Well

This setup is strong in a few specific ways.

- It creates real specialization instead of superficial agent names.
- It treats review as mandatory rather than optional.
- It keeps memory scoped to the project.
- It is unusually explicit about verification.
- It encodes cost discipline through prompt-caching behavior.
- It is portable because everything important lives in the repo itself.

## Current Assumptions And Limits

This pack is opinionated, and a few assumptions are baked in.

- It is designed for Claude Code, not generic chat clients.
- It assumes the `Agent` tool is available for true subagent delegation.
- The `photo` and `researcher` agents depend on their MCP backends actually being installed and runnable.
- The project-specific stack section in `CLAUDE.md` is still a placeholder, so adopters should fill that in per repo.
- `MEMORY.md` and `LESSONS.md` start mostly empty, which is correct for portability but means the pack gets better after real use.

## Best Use Cases

This pack makes the most sense when:

- tasks are non-trivial
- you want better separation between coding and review
- you work across multiple repos and want project isolation
- you care about predictable workflows, not just raw generation speed
- you want Claude Code to behave more like a small team than a single assistant

It is probably overkill for:

- tiny one-file edits
- purely conversational brainstorming
- projects where you do not want subagents or review gates

## How To Customize It

If someone wants to adapt this pack, the natural places are:

- update the project-specific section at the bottom of `CLAUDE.md`
- add more repo-specific lessons to `MEMORY.md`
- extend `.claude/rules/` with language or framework rules
- swap MCP backends in `.mcp.json` if better servers are available
- tune agent prompts to match the team's actual workflow

The safest customization pattern is to preserve the operating model and only tune the repo-specific parts.

## Quick Start

From the root of a target project:

```bash
unzip -o claude-agent-pack-2026-04-07.zip
./install.sh
```

Then restart Claude Code in that project so it reloads:

- `.claude/agents/*`
- `.claude/rules/*`
- `.mcp.json`

For non-trivial work, start with `orchestrator`.

For direct specialist calls, use the agent that owns the job:

- `@coder` for implementation
- `@debugger` for bug diagnosis
- `@reviewer` for review
- `@researcher` for live web information
- `@photo` for image operations

## Bottom Line

This repository is a disciplined Claude Code agent framework built around role separation, verification, scoped memory, and portable project-local configuration.

What makes it interesting is not just that it has multiple agents. It is that each one has a clearly defined job, tool boundary, and success contract, and the whole pack is designed to make Claude Code operate with more structure and less improvisation.
