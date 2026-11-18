## Writing style

Treat your final answer as the user's first look at your work, and not as a continuation of intermediate commentary. The final answer must always be fully self-contained: users should never need to read earlier commentary updates for context, since they are collapsed when the final answer is shown to the user.

Write the final answer and all other human-facing material anew for the intended reader. Do not copy or closely paraphrase your reasoning or adopt its writing style. Do not carry over working shorthand, jargon, or abbreviations from your reasoning, tool calls, or instructions to subagents and automations.

## Development Principles

- Iterate in small steps and get fast feedback.
- Follow the project's naming, layout, APIs, error handling, and toolchain.
- Make every change serve the current task. Meet current requirements without anticipating future frameworks or infrastructure.
- Allow local duplication; introduce abstractions only after multiple callers share a stable pattern.
- Make sure that code is human readable. Do not use fewer lines, shorter variable names, minified formatting, or dense one-liners as substitutes for simplicity. Ensure that comments and variable names are readable and understandable to a human. Code-golfed expressions count as overly complex when they encode many branches, conditions, or hidden assumptions.
- Avoid unnecessary indirection and abstraction. Helper functions, utility functions, and class abstractions can add cognitive complexity even when they do not add branches.

## Documentation

Record the project goal, introduction, installation, and usage in `README.md`.

Record only rationale, constraints, tradeoffs, operational knowledge, and important historical decisions that code cannot readily express.

Use C4 model, usually maintain C1 (System Context) and C2 (Container) over the long term.

## Verification & CI

Aim for sufficient confidence at a low maintenance cost: compilation or type checking, running the program, small samples of real input, targeted tests, or minimal reproductions.

Prioritize testing:

- Stable external behavior, public interfaces, and important invariants.
- Critical algorithms, known failure scenarios, and edge cases.

Choose the test level based on the problem:

- Pure logic and algorithms: property-based testing, differential tests.
- Module collaboration: integration tests, property-based testing.
- Critical real-world paths: end-to-end tests and property-based testing.

Use real implementations, fakes, or local test instances whenever possible, mock dependencies only when exceptional scenarios must be simulated.

CI should automatically run necessary checks, shorten the feedback cycle, and prevent obvious errors from entering the mainline. Provide a unified check entry point such as `make check` as needed.

## Version Control

Use Trunk-Based Development, with `main` as the only long-lived mainline. Use squash merge by default.

For a new, independent task, fetch the latest mainline, then create a new branch. Use short-lived branches such as `feat/...`, `fix/...`, or `refactor/...`. Use `git commit` often, keeping each commit independent and single-purpose. `git commit` format: `<subsystem>: <imperative description>`. Open a PR with `gh pr create --head feat/example --base main`.