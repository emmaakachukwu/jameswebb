# James Webb

James Webb is a CLI tool used for searching through repositories in a source control group or project. It supports both GitHub and GitLab platforms.

## Features

- Search through repositories or namespaces on GitHub and GitLab.
- Supports case-sensitive and case-insensitive searches.
- Displays search results with highlighted matching text.
- Configurable via environment variables and command-line options.

## Installation

To install the required gems, run:

```sh
bundle install
```

## Usage
To use the CLI tool, run the following command:

```sh
bin/webb --url <repository_or_namespace_url> <search_text>
```

## Examples
Search for "hello world" in a GitHub repository:

```sh
bin/webb --url https://github.com/emmaakachukwu/jameswebb 'hello world'
```

Search for "Gitlab" in a GitLab namespace:

```sh
bin/webb --url https://gitlab.com/gitlab-org --type namespace 'GitLab'
```

For more usage info, run:

```sh
bin/webb --help
```

## Configuration
You can configure the tool using environment variables:

- `WEBB_GITHUB_TOKEN`: GitHub personal access token.
- `WEBB_GITHUB_USER`: GitHub username or project name (default: JamesWebb).
- `WEBB_GITHUB_ENDPOINT`: GitHub API endpoint (default: https://api.github.com).
- `WEBB_GITLAB_TOKEN`: GitLab personal access token.
- `WEBB_GITLAB_ENDPOINT`: GitLab API endpoint (default: https://gitlab.com/api/v4).
- `WEBB_PLATFORM`: Platform to use for searching (either `github` or `gitlab`). Can be auto inferred from the `URL` argument when possible. Can also be specified using the `--platform` flag.

## Development
To run the tests, use the following command:

```sh
rspec
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/emmaakachukwu/jameswebb.
