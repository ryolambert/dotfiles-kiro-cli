---
name: mcp2cli
description: Turn any MCP server, OpenAPI spec, or GraphQL endpoint into a CLI with zero codegen. Use for discovering, testing, migrating, and managing MCP server configurations. Saves 96-99% of tokens wasted on tool schemas.
---

# mcp2cli — Universal MCP CLI

[mcp2cli](https://github.com/knowsuchagency/mcp2cli) turns any MCP server, OpenAPI spec, or GraphQL endpoint into a CLI at runtime with zero codegen. Saves 96–99% of tokens wasted on tool schemas every turn.

## When to Use

- **Discover** tools available on any MCP server (`--list`)
- **Test** MCP server tools directly from the command line before configuring them
- **Migrate** existing MCP server configurations into your Kiro CLI setup
- **Bake** frequently used MCP connections into named shortcuts
- **Audit** which tools an MCP server exposes (with `--search` filtering)
- **Generate** skills from OpenAPI specs or MCP servers

## Installation

```bash
# Run directly without installing
uvx mcp2cli --help

# Or install globally
uv tool install mcp2cli
```

## Quick Reference

### Discover MCP Server Tools

```bash
# List all tools from an MCP server
mcp2cli --mcp https://mcp.example.com/sse --list

# Search for specific tools
mcp2cli --mcp https://mcp.example.com/sse --search "search"

# List tools from a stdio MCP server
mcp2cli --mcp-stdio "npx @modelcontextprotocol/server-filesystem /tmp" --list

# Compact listing (names only, minimal tokens)
mcp2cli --mcp https://mcp.example.com/sse --list --compact
```

### Test MCP Tools

```bash
# Call a tool directly
mcp2cli --mcp https://mcp.example.com/sse search --query "test"

# Test a stdio server tool
mcp2cli --mcp-stdio "npx @upstash/context7-mcp" resolve-library-id --libraryName "react"
```

### Bake Connections (Save for Reuse)

```bash
# Save an MCP connection as a named shortcut
mcp2cli bake create myapi --mcp https://mcp.example.com/sse

# Save a stdio server
mcp2cli bake create mygit --mcp-stdio "npx @mcp/github"

# Use baked tools with @ prefix
mcp2cli @myapi --list
mcp2cli @myapi search --query "test"

# Install as a standalone CLI wrapper
mcp2cli bake install myapi
```

### Migrate Existing MCP Configs

To migrate an existing MCP server configuration into your Kiro CLI setup:

1. **Discover** — List tools from the existing server:
   ```bash
   mcp2cli --mcp-stdio "command args" --list --verbose
   ```
2. **Test** — Verify key tools work:
   ```bash
   mcp2cli --mcp-stdio "command args" tool-name --param value
   ```
3. **Bake** — Save as a named config:
   ```bash
   mcp2cli bake create name --mcp-stdio "command args"
   ```
4. **Add to Kiro** — Add the server to `generate-configs.sh` or `~/.kiro/settings/mcp.json`

### OpenAPI & GraphQL

```bash
# List endpoints from an OpenAPI spec
mcp2cli --spec https://api.example.com/openapi.json --list

# List queries from a GraphQL endpoint
mcp2cli --graphql https://api.example.com/graphql --list

# Generate a skill from an API
mcp2cli create a skill for https://api.example.com/openapi.json
```

## Token Savings

mcp2cli drastically reduces token overhead:
- Default `--list`: ~1,400 tokens for 96 tools
- Top 10 most-used, names only: ~20 tokens (`--list --top 10 --compact`)
- TOON output encoding: 40-60% fewer tokens than JSON (`--toon`)

## Output Modes

- `--pretty` — Pretty-print JSON (auto for TTY)
- `--raw` — Raw response body
- `--toon` — Token-efficient encoding for LLM consumption
- `--head N` — Limit output to first N records

## Integration with Kiro CLI

mcp2cli is available to all agents as a CLI tool via `execute_bash`. Use it to:
1. Audit and discover MCP server capabilities before adding them to configs
2. Test tool invocations without full MCP client setup
3. Migrate MCP configs from other AI tools (Claude, Cursor, Copilot, etc.)
4. Create baked shortcuts for frequently accessed APIs
