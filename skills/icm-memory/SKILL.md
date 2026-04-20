---
name: icm-memory
description: AI memory recall and storage via ICM (Infinite Context Memory). Use /recall to retrieve past decisions, patterns, and context. Use /remember to store important facts for future sessions.
---

# ICM Memory (Recall & Remember)

Persistent memory for AI agents powered by [ICM](https://github.com/rtk-ai/icm). Stores decisions, errors, preferences, and knowledge across sessions using hybrid search (FTS5 + vector).

## When to Use

- **Recall**: At the start of any task to check for prior decisions, known constraints, or past mistakes
- **Remember**: When you discover important facts, make architectural decisions, encounter errors with root causes, or learn project-specific constraints
- **Feedback**: When a prediction was wrong — record the correction for future reference

## Commands

### /recall — Search memories

Search for relevant memories before making decisions or starting work.

```
/recall <query>
```

Examples:
- `/recall database choice` — What database was chosen and why?
- `/recall auth setup` — How was authentication configured?
- `/recall deployment config` — What deployment decisions were made?

The ICM MCP server provides these recall tools:
- `icm_memory_recall` — Search memories by query, filter by topic/keyword
- `icm_memoir_search` — Search permanent knowledge graphs
- `icm_feedback_search` — Search past corrections before making predictions

### /remember — Store memories

Store important facts, decisions, and learnings for future sessions.

```
/remember <what to remember>
```

When storing, classify importance:
- **critical** — Never forgotten (architecture decisions, security constraints)
- **high** — Slow decay (important patterns, key preferences)
- **medium** — Normal decay (general decisions, standard patterns)
- **low** — Fast decay (temporary notes, session-specific context)

The ICM MCP server provides these storage tools:
- `icm_memory_store` — Store with auto-dedup (>85% similarity → update)
- `icm_memoir_add_concept` — Add to permanent knowledge graphs
- `icm_feedback_record` — Record corrections when predictions are wrong

## Best Practices

1. **Recall before deciding** — Always check if a decision was already made
2. **Store decisions with rationale** — Include the "why", not just the "what"
3. **Use topics** — Organize memories by project name for easy filtering
4. **Use keywords** — Tag memories with searchable keywords (e.g., `db,postgres,migration`)
5. **Consolidate periodically** — When a topic exceeds 7 entries, consolidate via `icm_memory_consolidate`
6. **Record corrections** — When you make a wrong prediction, use `icm_feedback_record`

## Memory Types

### Episodic (Memories)
Temporal, decaying memories for decisions, errors, preferences. Critical memories never fade.

### Semantic (Memoirs)
Permanent knowledge graphs with concepts linked by typed relations (`depends_on`, `contradicts`, `superseded_by`, etc.).

### Feedback
Corrections when AI predictions are wrong. Enables closed-loop learning.

## MCP Configuration

ICM is configured as an MCP server in `~/.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "icm": {
      "command": "icm",
      "args": ["serve", "--compact"]
    }
  }
}
```

## Auto-Extraction

ICM hooks automatically extract and inject memories:
- **Session start** (`icm-start.sh`) — Injects critical/high memories (~500 tokens)
- **Post tool use** (`icm-post.sh`) — Extracts facts from tool output
- **Pre-compact** (`icm-compact.sh`) — Saves memories before context compression
- **User prompt** (`icm-prompt.sh`) — Injects recalled context per prompt
