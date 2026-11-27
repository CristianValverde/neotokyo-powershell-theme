#!/bin/bash
set -euo pipefail
export NEOTOKYO_TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$NEOTOKYO_TEST_ROOT/tests/check.py"
zsh_binary=${NEOTOKYO_TEST_ZSH:-zsh}
test_home=$(mktemp -d)
trap 'rm -rf -- "$test_home"' EXIT
HOME="$test_home" ZDOTDIR="$test_home" TERM=xterm-256color "$zsh_binary" -fic 'source "$NEOTOKYO_TEST_ROOT/tests/shell.zsh"'
