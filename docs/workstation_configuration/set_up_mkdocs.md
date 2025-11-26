---
title: Documentation with mkdocs
authors:
    - McKraken
date: 21-Mar-2023
version: 0.1
mck:
    py_version: v3.11
tags:
    - mkdocs
---

## Local Development

A local environment should be configured to enable linting and building `mkdocs`[^mkdocs] locally. This enables testing changes locally before committing to a remote branch.

### Prerequisites

#### Python

1. This is currently using Python {{ mck.py_version }}.   A working `pyenv` installation is a good way to set this up.[^pyenv]
2. A working installation of Poetry for Python dependency management.[^poetry]

#### Clone Repository

1. Clone the repository to your local machine by running:
  
    ``` bash
    git clone **REPO_URL**
    ```

#### Local Environment Workflow Overview

1. Run your Terminal (or IDE) of choice.
2. Navigate to **REPO NAME** repository to the `docs/` sub-folder.

    !!! note
        There might be two levels of "docs" folders in the repo.  The first level is the base of the documentation area where `mkdocs` is run and the mkdocs.yml file lives.  The second level docs/ folder under this is where the actual documentation files live that are used to generate the static pages for the documentation site.

3. Run `poetry install` or `make install` to install the required Python packages in the poetry environment while located in the directory where the pyproject.toml file is.
4. (Optional) Run `poetry shell` to activate the poetry virtual environment.

    !!! tip
        There are a few options to get the tasks done.  
        1. Run `poetry shell` to activate the virtual environment shell and just run the commands in that virtual environment shell.  
        2. Prefix the commands with `poetry run` to run the command in the virtual environment without having to run `poetry shell` first.  
        3. A `Makefile` is provided with command shortcuts if this method is preferred.

        The following workflow steps will include the commands for options 1. and 3.  If you chose to use neither of those, then prefix each other command with `poetry run`

5. Create and checkout a new branch.
6. Edit or create any documentation as needed in the second level `docs` folder.
7. Run `pymarkdownlnt -c .pymarkdown-linting-cfg.json scan --recurse docs` (referencing the correct path to the linting configuration file) or `make lint` to lint the markdown, and make changes where necessary.

    !!!info
        Details for Markdown rules can be found [in the documentation](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md). If rules need to be ignored, update the linting configuration file.

8. Run `mkdocs serve` or `make serve` to run the mkdocs site locally and confirm the changes.
9. Push your changes to your branch on Github.
10. Create a Pull Request (PR) for someone to review your changes.
11. After PR review and approval, the changes can be merged into the main or master branch.

    !!! todo
        Set up Github Actions for the following deployment step, when available.

12. After the changes are merged, update your local repo `main` or `master` branch (`git pull` after checking out the correct branch).
Then, from your updated `main` or `master` branch, run `mkdocs gh-deploy` or `make deploy` to push the new site to the `gh-pages`
branch and make the changes to the documentation site live.

## Issues

### Create an issue

If you want to create, delete or update anything related to this repo, create an issue that aligns with the below:

- Add additional content to an existing category
- Creation of new category
- Spelling and grammar
- Linting for markdown

### Solve an issue

Scan through our existing issues to find one that needs addressing. If you find an issue to work on, work on the fix locally in a branch, check it locally, and then create a Pull Request (PR) with the fix.

## Branches

Try to use one of the following when creating branches for the documentation:

```bash
create/documentation-[DOC-NAME]
```

```bash
update/documentation-[DOC-NAME]
```

```bash
delete/documentation-[DOC-NAME]
```

## Making Changes

### Make Changes in the UI

Click on the edit icon at the top right of any of the pages to make small changes such as a typographic errors, grammar fixes, or a broken link. This takes you to the .md file where you can make your changes and create a pull request for a review.

### Make Changes Locally

#### Update Existing Content

1. Make changes required to the `index.md` of the existing category, eg: technical-solutions
1. Run linting command from local development environment to ensure you're following the Markdown rules, and resolve any issues
1. Run mkdocs server locally to ensure the site will successfully build without errors via your local development environment
1. Open `http://127.0.0.1:8000/` via browser and validate changes have applied as expected

#### Create New Category

1. Create a category folder
1. Create `index.md` within the folder created
1. Run linting command from your local development environment to ensure you're following the Markdown rules, and resolve any issues
1. Run mkdocs server locally to ensure the site will successfully build without errors via your local development environment
1. Open `http://127.0.0.1:8000/` via browser and validate changes have applied as expected

### Commits

#### Create Commit

- Review the content for accuracy before creating your commit
- Check your changes for grammar and spelling before creating your commit
- Keep commit messages short (<80 characters)
- Make an individual commit for each category
- Squash multiple commits

### Pull Requests

#### Create Pull Request

When you're finished with the changes, create a pull request (PR).

- Use imperative tense (e.g. "add" instead of "added" or "adding") in the PR title.
- Include application names, categories and a link to the project page in the description.
- Don't forget to link your PR to an issue[^pr-link] if you are solving one.
- We may ask for changes to be made before a PR can be merged, either using suggested changes[^suggest-changes] or pull request comments. You can apply suggested changes directly through the UI. You can make any other changes in your fork, then commit them to your branch.
- As you update your PR and apply changes, mark each conversation as resolved.[^resolved]
- If you run into any merge issues, checkout the git tutorial on "merge conflicts" and other issues[^merge-conflicts].

### Merge your PR

Congratulations 🎉🎉 the team thanks you ✨.

Once your PR is merged, your contributions can be pushed to the gh-pages branch and will be visible on Documentation Site.

## Relevant Documentation

[^mkdocs]: [https://www.mkdocs.org/](https://www.mkdocs.org/)
[^pyenv]: [https://github.com/pyenv/pyenv#simple-python-version-management-pyenv](https://github.com/pyenv/pyenv#simple-python-version-management-pyenv)
[^poetry]: [https://python-poetry.org/docs/#installation](https://python-poetry.org/docs/#installation)
[^pr-link]: [https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
[^suggest-changes]: [https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/incorporating-feedback-in-your-pull-request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/incorporating-feedback-in-your-pull-request)
[^resolved]: [https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/commenting-on-a-pull-request#resolving-conversations](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/commenting-on-a-pull-request#resolving-conversations)
[^merge-conflicts]: [https://github.com/skills/resolve-merge-conflicts](https://github.com/skills/resolve-merge-conflicts)
