## Principles

- Iterate in small steps and get fast feedback.
- Follow the project's naming, layout, APIs, error handling, and toolchain.
- Make every change serve the current task.
- Meet current requirements without anticipating future frameworks or infrastructure.
- When coding, prioritize correctness, clarity, simplicity, and maintainability, and make failures observable.
- Allow local duplication; introduce abstractions only after multiple callers share a stable pattern.
- When refactoring, preserve behavior and verify it with relevant tests, unless a change is explicitly requested.

## Architecture & Documentation

Record only rationale, constraints, tradeoffs, operational knowledge, and important historical decisions that code cannot readily express.

- `README.md`
    - Project management: the project goal, current milestone, and acceptance criteria.
    - Software: introduction, installation, usage, development workflow, current status, and important limitations.
- `docs/`: design and operational documentation that needs a separate explanation.
- `docs/architecture/`: architecture documentation.

When code or behavior changes, update relevant documentation as needed.

### C4 and Other Views

Usually maintain C1 and C2 over the long term; for simple projects, retain only views that help explain the system.

1. C1 — System Context: users, system responsibilities, and external systems.
1. C2 — Container: major runtime units, responsibilities, communication methods, protocols, and key technologies.
1. C3 — Component: only for containers that are complex, important, and difficult to understand from code.
1. C4 — Code: use code; do not maintain separate diagrams over the long term.

Add views of runtime interactions, deployment, relationships between systems, state machines, data relationships, control flow, or data flow as needed.

## Verification & CI

Aim for sufficient confidence at a low maintenance cost: compilation or type checking, running the program, small samples of real input, targeted tests, or minimal reproductions.

Do not pursue arbitrary coverage targets or require new tests for every change.

### Choosing Verification Methods

Prioritize testing:

- Stable external behavior, public interfaces, and important invariants.
- Critical algorithms, known failure scenarios, and edge cases prone to regression.

Avoid coupling tests to private implementations, temporary internal structures, or call ordering that has no semantic significance.

Choose the test level based on the problem:

- Pure logic and algorithms: unit tests, with property-based or differential testing when needed.
- Module collaboration: integration tests and property-based testing.
- Critical real-world paths: a small number of end-to-end tests and property-based testing.

Use real implementations, fakes, or local test instances whenever possible. Isolate or mock dependencies only when they are slow, expensive, unavailable, destructive, uncontrollable, or when exceptional scenarios must be simulated.

TDD is not mandatory. It is well suited to bug fixes, pure logic, algorithms, stable APIs, and features with clearly defined behavior.

When fixing bugs, prefer: reproduce → add a regression case → fix → verify.

### CI

- CI should automatically run necessary checks, shorten the feedback cycle, and prevent obvious errors from entering the mainline.
- Prefer maintaining the existing setup; provide a unified check entry point such as `make check` or `scripts/check` as needed.
- Checks should be fast, deterministic, reproducible, and relevant to the project; avoid slow, unstable, redundant, or low-value tasks.

## Version Control

Use Trunk-Based Development, with `main` as the only long-lived mainline, and keep it buildable, testable, and ready for integration.

Separate merging from releasing. Features that are not yet available can be integrated early through feature flags, internal implementations, or unpublished APIs.

### branches & PRs

- Use short-lived branches such as `feat/...`, `fix/...`, or `refactor/...`.
- Push updates throughout development.
- Open a draft PR early, `gh pr create --draft --head feat/example --base main`.
- Keep the PR title and description current as the work evolves.
- The PR description should cover related issues, purpose, verification results, and TODOs.
- Before merging, normally require CI and code review to pass, no conflicts with the latest `main`.
- Use squash merge by default so each PR corresponds to one logical commit on the mainline.

### Working Copy & Changes

- Inspect `git status` and `git log` before making changes.
- For a new, independent task, fetch the latest mainline, then create a new branch.
- `git commit` format: `<subsystem>: <imperative description>`. Explain rationale or tradeoffs in the body when they are not obvious.
- Use `git commit` often to start the next change, keeping each commit independent and single-purpose for easier review and rollback.
- Resolve conflicts in the affected files before continuing or pushing.
