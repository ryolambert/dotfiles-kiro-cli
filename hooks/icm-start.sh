#!/usr/bin/env bash
# ICM hook: agentSpawn — inject critical/high memories at session start (~500 tokens)
command -v icm &>/dev/null || exit 0
icm hook start 2>/dev/null
