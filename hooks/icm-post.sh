#!/usr/bin/env bash
# ICM hook: postToolUse — extract facts from tool output every N calls (auto-extraction)
command -v icm &>/dev/null || exit 0
icm hook post 2>/dev/null
