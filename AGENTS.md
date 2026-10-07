## Principles

- Iterate in small steps and get fast feedback.
- Follow the project's naming, layout, APIs, error handling, and toolchain.
- Make every change serve the current task.
- Meet current requirements without anticipating future frameworks or infrastructure.
- Allow local duplication; introduce abstractions only after multiple callers share a stable pattern.
- When refactoring, preserve behavior and verify it with relevant tests, unless a change is explicitly requested.

## Architecture & Documentation

Documentation explains the current system. Record only rationale, constraints, tradeoffs, operational knowledge, and important historical decisions that code cannot readily express.

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
1. C4 — Code: use code as the source of truth by default; do not maintain separate diagrams over the long term.

Add views of runtime interactions, deployment, relationships between systems, state machines, data relationships, control flow, or data flow as needed.

## Verification & CI

Aim for sufficient confidence at a low maintenance cost. Do not pursue arbitrary coverage targets or require new tests for every change.

### Choosing Verification Methods

During development, prefer the lowest-cost effective verification: compilation or type checking, running the program, small samples of real input, targeted tests, or minimal reproductions.

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

### Checks Before Completion

Choose checks relevant to the change, usually from cheapest to most expensive: format / lint / type check → targeted tests → integration tests → build → full suite

Add verification through actual execution as needed; successful compilation or passing tests alone does not prove that the intended behavior is correct.

### CI and Releases

- CI should automatically run necessary checks, shorten the feedback cycle, and prevent obvious errors from entering the mainline.
- Prefer maintaining the existing setup; provide a unified check entry point such as `make check` or `scripts/check` as needed.
- Checks should be fast, deterministic, reproducible, and relevant to the project; avoid slow, unstable, redundant, or low-value tasks.
- Without a remote repository, maintain local verification; with a remote repository, inspect existing CI first and extend it based on explicit requirements.
- Release manually by default; add CD only when there is an explicit need.

## Version Control

Use `jj` colocated with `git`: `.jj` and `.git` share the same working tree. Use `jj` for everyday version-control operations.

Use Trunk-Based Development, with `main@origin` as the only long-lived mainline, and keep it buildable, testable, and ready for integration.

Separate merging from releasing. Features that are not yet available can be integrated early through feature flags, internal implementations, or unpublished APIs.

### Working Copy & Changes

- Inspect `jj status`, `jj diff`, and `jj log` before making changes.
- For a new, independent task, fetch the latest mainline with `jj git fetch --remote origin`, then start a change with `jj new main@origin`. When continuing existing work, keep the current change and base.
- Use `jj describe -m '<description>'` to describe the current change. Format: `<subsystem>: <imperative description>`. Explain rationale or tradeoffs in the body when they are not obvious.
- Use `jj new` often to start the next change, keeping each commit independent and single-purpose for easier review and rollback.
- Resolve conflicts in the affected files and confirm the result with `jj status` and `jj diff` before continuing or pushing.

### Bookmarks & PRs

- Use short-lived bookmarks such as `feat/...`, `fix/...`, or `refactor/...` to publish changes as Git branches; aim for lifetimes of a few hours to a few days.
- Push updates to the task's bookmark throughout development, moving it to the intended PR tip whenever new changes are added.
- Push only the task's bookmark and open a draft PR early, once there is an initial change to review, using GitHub tooling such as `gh pr create --draft --head feat/example --base main`.
- Keep the PR title and description current as the work evolves. The description should cover related issues, purpose, verification results, and TODOs.
- Before merging, normally require CI and code review to pass, no conflicts with the latest `main`, and no unrelated changes.
- Use squash merge by default so each PR corresponds to one logical commit on the mainline.
- Changes used exclusively by one person can be synchronized with rebase. Do not rewrite shared history that multiple people already depend on.

## Coding

Prioritize correctness, clarity, simplicity, and maintainability, and make failures observable.

1. Types and Invariants
    - Use types to express real constraints; avoid building complex generic systems merely for type-level tricks.
    - Make important invariants explicit through types, assertions, input validation, or tests.
    - Expose states that should be impossible rather than silently accommodating them.
1. Error Handling
    - Do not swallow errors, report false success, use silent fallbacks / arbitrary defaults, or continue after ignoring exceptions.
    - Return or throw errors, propagate exceptions, or assert invariants according to the intended semantics.
    - Include the context needed to locate the problem in error messages.
1. Dependencies and Toolchain
    - Prefer the standard library, existing dependencies.
    - New dependencies should solve problems that existing tools cannot handle effectively and provide a clear net benefit considering maintenance status, adoption cost, and practical value.
    - Prefer stable, well-maintained options when adding tools.
1. Performance
    - Measure → locate the bottleneck → optimize → measure again.
    - Let measurements guide optimization, and verify correctness at the same time.
1. Long-Running Tasks
    - Save checkpoints, completed IDs, intermediate results, and necessary metadata as needed to support resumption.
    - When resuming, clearly distinguish completed, incomplete, and invalid states.
