# Kiro CLI Configuration

Multi-agent AI coding orchestrator powered by Kiro CLI. Features 17 specialized agents, 10 custom hooks, 26 skills, and a code-gen config pipeline.

## Architecture Overview

```
                        ┌─────────────────┐
                        │ code_supervisor  │  (ctrl+a)
                        │   orchestrator   │
                        └────────┬────────┘
                                 │ subagent tool
            ┌────────────────────┼────────────────────┐
            ▼                    ▼                     ▼
   ┌─────────────────┐  ┌──────────────┐  ┌────────────────────┐
   │  11 leaf agents  │  │  4 council   │  │  .plan/ folder     │
   │   (specialists)  │  │  agents      │  │  (inter-agent IPC) │
   └─────────────────┘  └──────────────┘  └────────────────────┘
```

- `code_supervisor` is the orchestrator — dispatches to leaf agents via the `subagent` tool
- 11 leaf agents: developer, reviewer, designer, explorer, simplifier, tester, debugger, planner, librarian, researcher, mcp2cli
- 4 council agents: councillor-a, councillor-b, councillor-c, council-master (multi-model consensus)
- All agent prompts use XML tag format (`<Role>`, `<Agents>`, `<Workflow>`, etc.)

## Quick Start

### Prerequisites

- `jq` (JSON processing)
- Node.js (for `npx` — MCP servers)
- Python 3 (for `uvx` — MCP servers)
- `rtk` (Rust Token Killer) — required for token-optimized shell command execution. Install from [https://github.com/rtk-ai/rtk](https://github.com/rtk-ai/rtk)
- `icm` (Infinite Context Memory) — persistent AI memory across sessions. Install from [https://github.com/rtk-ai/icm](https://github.com/rtk-ai/icm)
- `mcp2cli` (optional) — universal CLI for MCP servers, OpenAPI specs, and GraphQL endpoints. Install from [https://github.com/knowsuchagency/mcp2cli](https://github.com/knowsuchagency/mcp2cli)
- `cmux` (optional) — native macOS terminal for AI coding agents. Enables desktop notifications. Install from [https://github.com/manaflow-ai/cmux](https://github.com/manaflow-ai/cmux)
- `EXA_API_KEY` environment variable (for Exa search)

### Installation

```bash
# 1. Clone/copy this directory
cp -r .kiro ~/.kiro

# 2. Generate agent JSON configs from markdown prompts
chmod +x ~/.kiro/generate-configs.sh
~/.kiro/generate-configs.sh

# 3. Start
kiro-cli chat   # defaults to code_supervisor agent
```

## Agents

### Leaf Agents

| Agent | Role | Model | Shortcut |
|-------|------|-------|----------|
| developer | Code implementation | claude-opus-4.6 | `ctrl+shift+d` |
| reviewer | Code review & YAGNI enforcement | claude-opus-4.6 | `ctrl+r` |
| designer | Figma design extraction | claude-opus-4.6 | `ctrl+shift+f` |
| explorer | Codebase investigation | claude-opus-4.6 | `ctrl+e` |
| simplifier | Code refinement | claude-opus-4.6 | `ctrl+shift+s` |
| tester | Test suite design | claude-opus-4.6 | `ctrl+t` |
| debugger | Root cause investigation | claude-opus-4.6 | `ctrl+b` |
| planner | Execution plans | claude-opus-4.6 | `ctrl+p` |
| librarian | Library docs research | claude-opus-4.6 | `ctrl+l` |
| researcher | Academic paper search | claude-opus-4.6 | `ctrl+shift+r` |
| mcp2cli | MCP server management | claude-opus-4.6 | `ctrl+shift+m` |

### Orchestrator

| Agent | Role | Model | Shortcut |
|-------|------|-------|----------|
| code_supervisor | Orchestrator — dispatches to all leaf agents | claude-opus-4.6 | `ctrl+a` |

### Council Agents

| Agent | Model | Role |
|-------|-------|------|
| councillor-a | claude-opus-4.6 | Independent perspective A |
| councillor-b | GLM-5 | Independent perspective B |
| councillor-c | claude-opus-4.5 | Independent perspective C |
| council-master | claude-opus-4.6 | Synthesizes council consensus |

## Hooks

10 hooks total — 4 base hooks for all agents + 4 ICM memory hooks for all agents + 2 supervisor-only hooks.

| Hook | Trigger | Scope | Description |
|------|---------|-------|-------------|
| `rtk-rewrite.sh` | `preToolUse` (shell) | Most agents | Intercepts shell commands, rewrites via RTK for token efficiency. Blocks original and suggests rtk-prefixed version. |
| `rtk-rules.sh` | `agentSpawn` | Most agents | Injects RTK usage instructions into agent context at startup |
| `caveman.sh` | `agentSpawn` | All agents | Injects caveman speech style instruction |
| `icm-start.sh` | `agentSpawn` | All agents | Injects critical/high ICM memories at session start (~500 tokens) |
| `icm-post.sh` | `postToolUse` | All agents | Extracts facts from tool output every N calls (auto-extraction) |
| `icm-compact.sh` | `preCompact` | All agents | Extracts memories from transcript before context compression |
| `icm-prompt.sh` | `userPromptSubmit` | All agents | Injects recalled ICM context at the start of each user prompt |
| `phase-reminder.sh` | `userPromptSubmit` | code_supervisor | Reminds orchestrator of 6-phase workflow on every prompt |
| `cmux-notify.sh` | `stop` | code_supervisor | Desktop notification via cmux when response completes |

## RTK Integration

RTK (Rust Token Killer) is a CLI proxy that optimizes shell command output for token efficiency. Two-layer protection ensures agents always use it:

1. **`agentSpawn` hook** (`rtk-rules.sh`) — tells agents to use `rtk` prefix for shell commands at startup
2. **`preToolUse` hook** (`rtk-rewrite.sh`) — intercepts and rewrites commands if agents forget

> **Important:** `agentSpawn` hooks do NOT fire for subagent sessions, but `preToolUse` hooks DO. This is why both layers are needed.

## ICM Integration

[ICM (Infinite Context Memory)](https://github.com/rtk-ai/icm) gives agents persistent memory across sessions — not note-taking, real memory with temporal decay, knowledge graphs, and hybrid search.

### What ICM Provides

- **Episodic Memory** — Store/recall decisions, errors, preferences with importance-based decay
- **Semantic Memory (Memoirs)** — Permanent knowledge graphs with typed relations
- **Feedback Loop** — Record corrections when AI predictions are wrong
- **Hybrid Search** — FTS5 BM25 (30%) + cosine similarity (70%) for accurate recall
- **Auto-Extraction** — Rule-based fact extraction from tool output (zero LLM cost)

### Install

```bash
# Homebrew (macOS / Linux)
brew tap rtk-ai/tap && brew install icm

# Quick install
curl -fsSL https://raw.githubusercontent.com/rtk-ai/icm/main/install.sh | sh
```

### How It's Used Here

ICM is integrated via both **MCP server** and **hooks**:

1. **MCP Server** (`icm serve --compact`) — Added to `mcp.json`, provides 27 tools for memory store/recall/memoirs/feedback/transcripts
2. **4 Hooks** — Automatically injected into all agents:
   - `icm-start.sh` (`agentSpawn`) — Injects critical/high memories at session start (~500 tokens)
   - `icm-post.sh` (`postToolUse`) — Extracts facts from tool output every N calls
   - `icm-compact.sh` (`preCompact`) — Extracts memories before context compression
   - `icm-prompt.sh` (`userPromptSubmit`) — Injects recalled context per user prompt
3. **Skill** (`icm-memory`) — Provides `/recall` and `/remember` usage guidelines

All hooks include graceful degradation — if `icm` is not installed, they silently exit.

### Dashboard

```bash
icm dashboard    # Interactive TUI with 5 tabs: Overview, Topics, Memories, Health, Memoirs
```

## mcp2cli Integration

[mcp2cli](https://github.com/knowsuchagency/mcp2cli) turns any MCP server, OpenAPI spec, or GraphQL endpoint into a CLI at runtime — zero codegen, saving 96–99% of tokens wasted on tool schemas.

### Install

```bash
# Run directly without installing
uvx mcp2cli --help

# Or install globally
uv tool install mcp2cli
```

### How It's Used Here

A dedicated **mcp2cli agent** (`ctrl+shift+m`) handles MCP server management:

- **Discover** tools on any MCP server (`mcp2cli --mcp <url> --list`)
- **Test** MCP tools directly from CLI before configuring them
- **Migrate** configs from other AI tools (Claude Desktop, Cursor, Copilot, VS Code)
- **Bake** frequently used connections into named shortcuts (`mcp2cli bake create`)
- **Audit** existing MCP setup for available/disabled tools

The mcp2cli skill is also available to all agents for ad-hoc MCP discovery.

## Skills

| Skill | Description |
|-------|-------------|
| cartography | Generate hierarchical codemaps for unfamiliar repositories |
| council-session | Multi-model consensus via subagent DAG |
| simplifier | Code refinement and complexity reduction |
| get-code-context-exa | Code context search via Exa (GitHub, StackOverflow, docs) |
| web-search-advanced-research-paper-exa | Academic paper search via Exa |
| icm-memory | AI memory recall and storage via ICM — `/recall` to search past decisions, `/remember` to store facts |
| mcp2cli | Universal MCP CLI — discover, test, migrate, and manage MCP servers |
| [Caveman](https://github.com/juliusbrussee/caveman) | ~75% output token reduction via terse caveman-speak. 5 sub-skills (caveman, caveman-commit, caveman-compress, caveman-help, caveman-review). Intensity levels: `lite`, `full` (default), `ultra`. Also injected via `hooks/caveman.sh` for persistent caveman speech across all agents. |
| [Grill Me](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md) | Interview/stress-test skill — relentlessly grills you on plans and designs, walking each branch of the decision tree until reaching shared understanding |

> **Additional skills** available at [github.com/vercel-labs/skills](https://github.com/vercel-labs/skills)

## cmux Integration

[cmux](https://github.com/manaflow-ai/cmux) is a native macOS terminal application built on top of Ghostty (libghostty), designed for developers running multiple AI coding agents in parallel. It provides notification rings, workspace management, and a scriptable CLI — purpose-built for agent workflows.

### Install

**Homebrew:**
```bash
brew tap manaflow-ai/cmux
brew install --cask cmux
```

**Or download the DMG:** [cmux-macos.dmg](https://github.com/manaflow-ai/cmux/releases/latest/download/cmux-macos.dmg)

**CLI setup** (for use outside cmux terminals):
```bash
sudo ln -sf "/Applications/cmux.app/Contents/Resources/bin/cmux" /usr/local/bin/cmux
```

### How it's used here

The `cmux-notify.sh` hook (triggered on `stop` for `code_supervisor`) sends a desktop notification via `cmux notify` whenever the orchestrator finishes responding. The cmux sidebar tab lights up with a blue notification ring showing the project name and a preview of the response — useful when managing multiple Kiro CLI sessions across workspaces.

The hook includes a guard clause (`cmux ping || exit 0`) so it silently does nothing if cmux is not installed or not running.

## MCP Servers

| Server | Transport | Description |
|--------|-----------|-------------|
| git | `uvx mcp-server-git` | Git operations |
| context7 | `npx @upstash/context7-mcp` | Library documentation lookup |
| figma-developer-mcp | `npx figma-developer-mcp` | Figma design extraction |
| [exa](https://github.com/exa-labs/exa-mcp-server) | Remote URL | Web search and research |
| github-grep | Remote URL (`mcp.grep.app`) | GitHub code search |
| [icm](https://github.com/rtk-ai/icm) | `icm serve --compact` | Persistent AI memory (27 MCP tools) |

## Configuration Pipeline

`generate-configs.sh` is the single source of truth.

```
  .md prompt files ──┐
                     ├──▶ generate-configs.sh ──▶ .json agent configs
  .sh hook scripts ──┘         (runtime)           (gitignored)
```

- `.md` prompt files and `.sh` hook scripts are **git-tracked**
- `.json` agent configs are **generated at runtime** (gitignored)
- Hook injection: 4 base hooks applied to all agents + 2 supervisor-only hooks

## Plan Folder Protocol

`.plan/<task-name>/` is the inter-agent communication directory. Agents read and write standardized files to coordinate work.

| File | Purpose |
|------|---------|
| `exploration-brief.md` | Explorer's codebase analysis |
| `task.md` | Full task requirements |
| `questions.md` | Planner's clarifying questions |
| `answers.md` | User's answers to questions |
| `dev-notes.md` | Developer's implementation notes |
| `design-spec.md` | Designer's UI specification |
| `simplifier-notes.md` | Simplifier's refinement notes |
| `test-notes.md` | Tester's test plan |
| `review.md` | Reviewer's code review |
| `feedback-investigation.md` | Debugger's investigation |
| `librarian-research.md` | Librarian's research findings |

## Settings

| Setting | Value |
|---------|-------|
| Default agent | `code_supervisor` |
| Default model | `claude-opus-4.6` |
| Thinking mode | Enabled |
| Tangent mode | Enabled |
| Diff tool | `delta --side-by-side --paging=never` |

## Key Design Patterns

1. **Code-gen over config** — markdown prompts are the source of truth; JSON configs are generated
2. **Hook injection** — behavior injected at runtime via shell hooks, not baked into prompts
3. **Separation of concerns** — each agent has a single responsibility
4. **Plan folder protocol** — standardized file-based IPC between agents
5. **Parallel wave execution** — supervisor dispatches independent tasks concurrently
6. **Multi-model council consensus** — diverse models debate for high-stakes decisions
