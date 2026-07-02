# Contributing to BooBoo

BooBoo is a ghost with opinions — but it welcomes friends who share its values.

## Values

- **Privacy-first.** No telemetry, no cloud, no data leaving the machine.
- **Simple over clever.** Readable code beats clever code. A single function beats a class hierarchy.
- **User consent.** Every system change requires explicit user confirmation.
- **No emojis.** Not in code, not in docs, not in commits.

## Getting Started

1. Fork the repo.
2. Clone your fork.
3. Run `swift build` to verify your toolchain works.
4. Look for [good first issues](https://github.com/krishnasureshcpa/BooBoo/labels/good%20first%20issue).

## Development Workflow

1. Create a branch: `git checkout -b your-feature-name`
2. Make changes. Keep commits small and focused.
3. Run `swift build` — it must pass.
4. Push and open a pull request.

### Code Style

- Match the existing style. Read a few files first.
- Use `let` over `var`. Use ternaries over reassignment.
- No `try!` or `fatalError()` in production code.
- No `as any`, `@ts-ignore`, or type suppressions.
- Prefer `guard`/`let` over forced unwrapping.
- Comments explain *why*, not *what*.

### Testing

- Add tests for new functionality.
- Run `swift test` before pushing.
- Tests run from the package directory, not repo root.

## Pull Request Process

1. Title follows conventional commits: `type(scope): summary`.
   Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.
2. Description explains what changed and why.
3. CI must pass.
4. At least one reviewer must approve.

## Questions?

Open a [Discussion](https://github.com/krishnasureshcpa/BooBoo/discussions) or ask BooBoo itself — the app has a built-in guide.
