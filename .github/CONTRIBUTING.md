# Contributing to Later

## Pull Request Guidelines

We use **squash merging** for all pull requests and follow [Conventional Commits](https://www.conventionalcommits.org/) for automated semantic versioning.

### Important: PR Title Format

**Your PR title determines the version bump** - it becomes the commit message on `main` after squash merge.

Individual commits in your feature branch can use any format - only the PR title matters.

### PR Title Format

```
<type>(<scope>): <description>
```

### Types

- **feat**: New feature (triggers MINOR version bump, e.g., 1.0.0 → 1.1.0)
- **fix**: Bug fix (triggers PATCH version bump, e.g., 1.0.0 → 1.0.1)
- **docs**: Documentation changes (no version bump)
- **style**: Code style changes (formatting, no logic change)
- **refactor**: Code refactoring (no feature or bug fix)
- **test**: Adding or updating tests
- **chore**: Maintenance tasks (dependencies, config, etc.)
- **perf**: Performance improvements
- **ci**: CI/CD configuration changes

### Breaking Changes

To trigger a MAJOR version bump (e.g., 1.0.0 → 2.0.0), add `!` after the type:

```
feat!: change API endpoint structure
```

Or include `BREAKING CHANGE:` in the PR description.

### Examples

**Good PR titles:**
- `feat(notes): add full-text search for notes`
- `fix(auth): resolve session timeout issue`
- `docs: update installation instructions`
- `refactor(ui): simplify button component structure`
- `test(models): add tests for TodoList serialization`
- `feat!: migrate to new authentication system` (MAJOR bump)

**Bad PR titles:**
- `Update stuff` (no type, unclear description)
- `Fix bug` (not lowercase, not specific enough)
- `feat:add feature` (missing space after colon)
- `Added new search feature` (wrong tense, no type)

### Version Mapping

- `feat:` in PR title → Bump MINOR version (1.0.0 → 1.1.0)
- `fix:` in PR title → Bump PATCH version (1.0.0 → 1.0.1)
- `feat!:` or `BREAKING CHANGE:` → Bump MAJOR version (1.0.0 → 2.0.0)
- Other types (`docs:`, `chore:`, etc.) → No version bump

### Workflow

1. Create feature branch with any commit style you prefer
2. Open PR with conventional commit format in **title**
3. PR checks run automatically (build, test, analyze)
4. After approval, merge with **squash merge**
5. PR title becomes commit on `main`
6. Deployment workflow automatically calculates version and publishes to Play Store
