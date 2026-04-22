#!/usr/bin/env bash
# ICM hook: preCompact — extract memories from transcript before context compression
command -v icm &>/dev/null || exit 0
icm hook compact 2>/dev/null
