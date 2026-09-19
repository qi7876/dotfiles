#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

"$repo_dir/tests/test_repository.sh"
"$repo_dir/tests/test_zsh_behavior.sh"
"$repo_dir/tests/test_install.sh"
