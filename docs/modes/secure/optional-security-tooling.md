# Optional Security Tooling

Use this as a shortlist when the scaffold needs stronger automated security checks later.

These tools are optional.
The scaffold should stay useful without them.

## Secret Detection

### `detect-secrets`

- GitHub: https://github.com/Yelp/detect-secrets
- Good for baseline-style secret detection in large repositories.
- Useful when you want to prevent new secrets without cleaning historical findings all at once.

### `Semgrep Secrets`

- Docs: https://semgrep.dev/docs/semgrep-secrets/getting-started
- Good for secret scanning with validation-oriented workflows.
- Better suited when a team later wants centralized scanning and triage.

## Static Security Analysis

### `CodeQL`

- Repo: https://github.com/github/codeql
- Good for source-backed security queries such as injection, unsafe sinks, and path problems.
- Best fit when the repo gains real application code or GitHub code scanning workflows.

### `Semgrep`

- Docs: https://semgrep.dev/docs/
- Good for lightweight custom rules and OWASP-aligned checks.
- Best fit when the team wants fast custom rules without building a full engine.

## Dependency Risk

### `OWASP Dependency-Check`

- Project: https://owasp.org/www-project-dependency-check/
- Repo: https://github.com/dependency-check/DependencyCheck
- Good for software composition analysis and known vulnerable dependency checks.
- Best fit when the repo starts carrying real app dependencies.

## Adoption Rule

- Do not add heavy scanners just because they exist.
- Add them only when the repo has enough real app code, dependencies, or auth flows to justify the maintenance cost.
- Keep local rules and hooks useful even if no external scanner is installed.
