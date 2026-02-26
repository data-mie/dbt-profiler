# Contributing to `dbt-profiler`

Thanks for your interest in contributing to `dbt-profiler`! We welcome improvements, fixes, and new features from the community. Before you begin, please review this document to understand how we collaborate.

We ask that you first discuss any significant changes via issue, email, or another form of communication before opening a pull request.

Please also take a moment to review our Code of Conduct and follow it in all interactions with the project and community.

## Pull Request Process

To ensure a smooth development workflow and high-quality contributions, please follow these guidelines when submitting a pull request:

### 1. Branch Naming Convention

Use clear and consistent branch names. Prefix your branch with:

- `feat/` for new features  
  _Example: `feat/add-skew-measure`_
- `fix/` for bug fixes  
  _Example: `fix/avg-calculation-bigquery`_

Note: The GitHub repository is configured to **automatically delete head branches after merge**, so you don’t need to clean up manually.

### 2. CI Checks

Pull requests will trigger a CircleCI pipeline with the following checks:

- ✅ `integration-postgres` – runs automatically on all PRs.
- ✅ `integration-sqlserver` – runs automatically on all PRs.
- 🔒 `integration-bigquery` – requires **explicit approval from a maintainer** in the CircleCI UI before running (due to usage of limited credentials).
- 🔒 `integration-snowflake` – requires **explicit approval from a maintainer** in the CircleCI UI before running (due to usage of limited credentials).
- 🔒 `integration-snowflake-fusion` – runs the same tests as `integration-snowflake` but using [dbt Fusion](https://docs.getdbt.com/docs/fusion/about-fusion) instead of dbt Core, to verify compatibility with the new Rust-based engine. Requires **explicit approval from a maintainer**.

Please ensure all checks pass before requesting a review or merging the PR.

### 3. Pull Request Requirements

- Provide a **clear and descriptive title** for your PR.
  - Avoid vague titles like "fix BigQuery adapter".
  - Prefer descriptive ones like "Fix avg calculation in the BigQuery adapter".
- Update the [README.md](README.md) with details of:
  - New macros
  - Changes to existing macros or functionality
- Add or update tests where relevant.
- Ensure the PR has been reviewed and approved by at least one maintainer before merging.

## Release Process

We follow [Semantic Versioning (semver)](https://semver.org/), using the format `MAJOR.MINOR.PATCH` (e.g., `0.9.0`).

Only maintainers may publish new releases. Here's the process:

1. **Prepare the Release**
   - Ensure all merged PRs intended for the release have clear and descriptive titles. This improves the quality of the auto-generated release notes.
   - Confirm that the `README.md` and other relevant documentation are up to date.

2. **Create the Release on GitHub**
   - Go to the [Releases](https://github.com/data-mie/dbt-profiler/releases) section of the GitHub repository.
   - Click **"Draft a new release"**.
   - Set the **tag version** (e.g., `0.9.0`) and choose the same as the **release title**.
   - Click **"Generate release notes"** to auto-populate a changelog based on merged PRs. Review and edit if necessary.
   - Click **"Publish release"**.

3. **Post-release**
   - Once published, the new version will automatically be picked up by [dbt Hub](https://hub.getdbt.com/). No manual publishing steps are required.
   - Optionally, announce the release in relevant channels (e.g., dbt Slack).

> **Tip:** A well-written PR title = a better changelog. Help your future self and others by being descriptive!

## Code of Conduct

### Our Pledge

In the interest of fostering an open and welcoming environment, we as
contributors and maintainers pledge to making participation in our project and
our community a harassment-free experience for everyone, regardless of age, body
size, disability, ethnicity, gender identity and expression, level of experience,
nationality, personal appearance, race, religion, or sexual identity and
orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment
include:

* Using welcoming and inclusive language
* Being respectful of differing viewpoints and experiences
* Gracefully accepting constructive criticism
* Focusing on what is best for the community
* Showing empathy towards other community members

Examples of unacceptable behavior by participants include:

* The use of sexualized language or imagery and unwelcome sexual attention or
advances
* Trolling, insulting/derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information, such as a physical or electronic
  address, without explicit permission
* Other conduct which could reasonably be considered inappropriate in a
  professional setting

### Our Responsibilities

Project maintainers are responsible for clarifying the standards of acceptable
behavior and are expected to take appropriate and fair corrective action in
response to any instances of unacceptable behavior.

Project maintainers have the right and responsibility to remove, edit, or
reject comments, commits, code, wiki edits, issues, and other contributions
that are not aligned to this Code of Conduct, or to ban temporarily or
permanently any contributor for other behaviors that they deem inappropriate,
threatening, offensive, or harmful.

### Scope

This Code of Conduct applies both within project spaces and in public spaces
when an individual is representing the project or its community. Examples of
representing a project or community include using an official project e-mail
address, posting via an official social media account, or acting as an appointed
representative at an online or offline event. Representation of a project may be
further defined and clarified by project maintainers.

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be
reported by contacting the project team at simo@datamie.fi. All
complaints will be reviewed and investigated and will result in a response that
is deemed necessary and appropriate to the circumstances. The project team is
obligated to maintain confidentiality with regard to the reporter of an incident.
Further details of specific enforcement policies may be posted separately.

Project maintainers who do not follow or enforce the Code of Conduct in good
faith may face temporary or permanent repercussions as determined by other
members of the project's leadership.

### Attribution

This Code of Conduct is adapted from the [Contributor Covenant][homepage], version 1.4,
available at [http://contributor-covenant.org/version/1/4][version]

[homepage]: http://contributor-covenant.org
[version]: http://contributor-covenant.org/version/1/4/