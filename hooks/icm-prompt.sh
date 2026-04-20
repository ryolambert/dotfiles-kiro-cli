#!/usr/bin/env bash
# ICM hook: userPromptSubmit — inject recalled context at the start of each user prompt
command -v icm &>/dev/null || exit 0
icm hook prompt 2>/dev/null
