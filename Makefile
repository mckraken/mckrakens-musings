# Awesome Elastic Engineering Development Environment
SHELL=/bin/bash

# Visual Studio devcontainers
build-container:
	mkdocs build

lint-container:
	@./scripts/markdown-lint.sh

serve-container:
	mkdocs serve

# poetry
install:
	poetry install

build:
	poetry run mkdocs build

lint:
	@poetry run ./scripts/markdown-lint.sh || true

serve:
	poetry run mkdocs serve

deploy:
	poetry run mkdocs gh-deploy

check:
	poetry run pre-commit run --all-files
