# Contributing

When contributing we follow semantic versioning and [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) in our Pull Requests and releases. You must prefix your PR and commit name with a type as below as well as a scope to identify what has changed, e.g. `type(scope): - Description`. Releases will be calculated based on PR labels that are automatically applied based on the PR title. Therefore the PR title needs also to follow the same rules as semantic commit.

Available types to use in your PR:

- feat: A new feature
- fix: A bugfix
- docs: Documentation only changes
- style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- refactor: A code change that neither fixes a bug nor adds a feature
- perf: A code change that improves performance
- test: Adding missing tests or correcting existing tests
- build: Changes that affect the build tool or external dependencies (example scopes: gulp, broccoli, npm)
- ci: Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- chore: Other changes that don't modify src or test files
- revert: Reverts a previous commit

This is enforced by the workflow [`semantic_commit_check.yaml`](.github/workflows/pr-lint.yaml) which is run on every PR.

## Releasing

Releases are automatically generated based on the PR labels automatically added with [workflow](.github/workflows/release.yml)
