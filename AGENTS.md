## Workflow

Basic loop: understand the requirements → read the relevant code → confirm current behavior → make the smallest viable change → verify → refactor if needed

- Iterate in small steps: break large requirements into steps that can be implemented, verified, and merged independently.
- Get fast feedback: use compilation, type checking, targeted tests, or actual execution early to confirm results.
- Follow existing conventions: before making changes, review the README, configuration, neighboring modules, similar implementations, tests, and CI as needed; follow the project's naming, layout, APIs, error handling, and toolchain.
- Control scope: every change should serve the current task; handle unrelated issues and large refactors separately.
- Implement only what is needed: address current requirements without anticipating frameworks, plugin systems, or infrastructure.
- Abstract carefully: allow a little local duplication; introduce abstractions only after multiple callers actually share stable semantics and boundaries.
- Preserve behavior when refactoring: unless a change is explicitly requested, preserve existing external behavior and verify it with relevant tests.

## Architecture & Documentation

Documentation explains the current system. Record only rationale, constraints, tradeoffs, operational knowledge, and important historical decisions that code cannot readily express.

- `README.md`
  - Project management: the project goal, current milestone, and acceptance criteria.
  - Software: introduction, installation, usage, development workflow, current status, and important limitations.
- `docs/`: design and operational documentation that needs a separate explanation.
- `docs/architecture/`: architecture documentation.

When code or behavior changes, update relevant documentation as needed. Comments should explain non-obvious behavior, dangerous assumptions, and external requirements rather than restating the code.

### C4 and Other Views

Usually maintain C1 and C2 over the long term; for simple projects, retain only views that help explain the system.

1. C1 — System Context: users, system responsibilities, and external systems.
1. C2 — Container: major runtime units, responsibilities, communication methods, protocols, and key technologies.
1. C3 — Component: only for containers that are complex, important, and difficult to understand from code.
1. C4 — Code: use code as the source of truth by default; do not maintain separate diagrams over the long term.

Add views of runtime interactions, deployment, relationships between systems, state machines, data relationships, control flow, or data flow as needed.

Let architecture evolve with real requirements: direct implementation → recurring requirements → stable boundaries → abstraction.

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

Choose checks relevant to the change, usually from cheapest to most expensive:

```text
format / lint / type check → targeted tests → integration tests → build → full suite
```

Add verification through actual execution as needed; successful compilation or passing tests alone does not prove that the intended behavior is correct.

### CI and Releases

- CI should automatically run necessary checks, shorten the feedback cycle, and prevent obvious errors from entering the mainline.
- Prefer maintaining the existing setup; provide a unified check entry point such as `make check` or `scripts/check` as needed.
- Checks should be fast, deterministic, reproducible, and relevant to the project; avoid slow, unstable, redundant, or low-value tasks.
- Without a remote repository, maintain local verification; with a remote repository, inspect existing CI first and extend it based on explicit requirements.
- Release manually by default; add CD only when there is an explicit need.

## Git

Use Trunk-Based Development, with `main` as the only long-lived mainline, and keep it buildable, testable, and ready for integration.

Separate merging from releasing. Features that are not yet available can be integrated early through feature flags, internal implementations, or unpublished APIs.

### Commit

Recommended format:

```text
<subsystem>: <imperative description>
```

For example: `attention: handle empty sequences`. Keep descriptions concise and specific, and use the imperative mood; explain rationale or tradeoffs in the body when they are not obvious.

### Branch & PR

- Create a new branch before implementing any requirement or changing any code. Each branch should cover one scope; open a PR when the work is complete.
- Create short-lived branches from the latest `main`, such as `feat/...`, `fix/...`, or `refactor/...`; aim for lifetimes of a few hours to a few days.
- Each PR should represent one clear logical change; split large requirements into multiple PRs that can be merged independently.
- PR descriptions should explain the problem, purpose, implementation, important decisions or tradeoffs, and verification results.
- Before merging, normally require passing CI and code review, no conflicts with the latest `main`, and no unrelated changes.
- Use squash merge by default so each PR corresponds to one logical commit on the mainline; delete branches that are no longer needed after merging.

Branches used exclusively by one person can be synchronized with rebase:

```bash
git fetch origin
git rebase origin/main
```

Do not rebase public history that multiple people already depend on.

## Coding

Prioritize correctness, clarity, simplicity, and maintainability, and make failures observable.

### Types and Invariants

- Use types to express real constraints; avoid building complex generic systems merely for type-level tricks.
- Make important invariants explicit through types, assertions, input validation, or tests.
- Expose states that should be impossible rather than silently accommodating them.

### Error Handling

- Do not swallow errors or report false success.
- Unless product semantics explicitly require it, do not use silent fallbacks, arbitrary defaults, or continue after ignoring exceptions.
- Return or throw errors, propagate exceptions, or assert invariants according to the intended semantics.
- Include the context needed to locate the problem in error messages.

### Dependencies and Toolchain

Prefer the standard library, existing dependencies, and the project's toolchain. New dependencies should solve problems that existing tools cannot handle effectively and provide a clear net benefit considering maintenance status, adoption cost, and practical value.

Do not introduce large dependencies for a small amount of helper code; prefer stable, well-maintained options when adding tools.

### Performance

Measure → locate the bottleneck → optimize → measure again. Let measurements guide optimization, and verify correctness at the same time.

### Long-Running Tasks

For long-running tasks that produce results continuously, save checkpoints, completed IDs, intermediate results, and necessary metadata as needed to support resumption. When resuming, clearly distinguish completed, incomplete, and invalid states; do not guess progress.

## Done

Before finishing, confirm:

- The requested behavior is implemented, relevant behavior is verified, and necessary checks pass.
- Error handling is explicit, with no unrelated changes or unnecessary complexity.
- Valuable tests and necessary documentation are updated, and the change can be safely integrated into `main`.

Add only work that actually improves correctness, feedback speed, and long-term maintainability.
