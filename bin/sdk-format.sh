#!/usr/bin/env bash

# Helper Script to run clang-format and print format mismatches in Red

set -e

if [ -f "./format-check.sh" ]; then
	export CLANG_FORMAT=clang-format-6.0
	./format-check.sh | awk '{print $1;}' | xargs --no-run-if-empty run-clang-format.py --color=always --clang-format-executable clang-format-6.0
fi
