#! /bin/bash
set -e

# Run pymarkdown to lint markdown for mkdocs
pymarkdownlnt -c .pymarkdown-linting-cfg.json scan --recurse docs
