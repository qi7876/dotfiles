## How to Code

核心目标：

> 优先优化反馈周期。保持修改小、系统可运行、主线可集成；只为已经出现的问题增加复杂度。

优先选择简单、明确、可验证、易维护的方案。不要为了未来需求提前建立复杂架构，也不要机械增加流程、测试、抽象或文档。

## Development Workflow

采用小步迭代：

```text
理解需求
→ 阅读相关代码和约定
→ 确认当前行为
→ 选择最小可行修改
→ 实现
→ 验证实际结果
→ 必要时重构
→ 下一小步
```

遵循：

1. **Small Changes**：大型需求拆成可独立实现、验证和合入的小步骤。
1. **Fast Feedback**：修改后尽早运行 compiler、type checker、lint、targeted tests 或实际程序。
1. **Working Software**：优先通过实际运行确认行为。
1. **YAGNI**：只实现当前需求，不提前建立 framework、plugin system、generic abstraction 或 infrastructure。
1. **Evidence Before Abstraction**：重复模式和稳定边界真正出现后再抽象。
1. **Scope Control**：每一处修改都应属于当前任务；无关问题单独处理。
1. **Preserve Behavior**：除非明确要求，否则重构保持现有外部行为。
1. **Existing Code First**：优先遵循已有 naming、layout、API、error、configuration、testing 和 dependency conventions。

修改前根据需要检查：

```text
README
project configuration
architecture documents
tests / CI
neighboring modules
similar implementations
```

不要仅因为另一种实现“更现代”或“更漂亮”就主动重写已有代码。

## Architecture

架构文档用于解释当前系统，而不是预测未来系统。

只记录难以从代码直接理解的信息，以及重要 constraints 和 trade-offs。

统一放在：

```text
docs/architecture/
```

### C4

长期维护：

- **C1 — System Context**：用户、系统职责、外部系统。
- **C2 — Container**：主要运行单元及 responsibility、communication、protocol、major technology。

按需维护：

- **C3 — Component**：仅用于复杂、重要且难以从代码理解的 Container。
- **C4 — Code**：默认以代码本身为准，不长期维护。

其他视图按需使用：

- Dynamic Diagram：运行时交互
- Deployment Diagram：软件与基础设施
- System Landscape Diagram：系统间关系
- State Machine Diagram：状态转换
- ER Diagram：数据关系
- Flowchart：控制流
- Data Flow Diagram：数据流

架构演化优先：

```text
direct implementation
→ repeated real need
→ stable boundary
→ abstraction
```

而不是：

```text
predict future
→ create abstraction
→ force current code into it
```

## Test & Verification

测试的目标是以尽可能低的维护成本提供足够的工程信心，而不是追求覆盖率。

开发过程中优先使用最低成本的有效验证：

```text
compiler / type checker
running the program
small real input
targeted test
minimal reproduction
```

系统稳定后，再逐步完善测试体系。

优先测试：

```text
stable external behavior
important invariants
known failure cases
critical algorithms
public interfaces
```

避免测试：

```text
private implementation details
temporary internal structure
meaningless call order
arbitrary coverage targets
```

测试层级：

- 纯逻辑和算法：unit / property / differential test
- 模块协作：integration test
- 关键真实路径：少量 E2E

尽量少使用 mock。只有真实依赖 slow、expensive、unavailable、destructive、uncontrollable，或需要制造异常场景时才隔离。优先真实实现、fake 或本地测试实例。

不强制 TDD。它更适合 bug fixing、pure logic、algorithm、stable API 和行为明确的功能。

Bug fixing 优先：

```text
reproduce
→ regression case
→ fix
→ verify
```

完成修改前选择与当前变化相关的检查，通常从便宜到昂贵：

```text
format / lint / type check
→ targeted test
→ integration test
→ build
→ full test suite
→ runtime verification
```

不要因为 code compiles 或 all tests pass 就直接认为行为正确。

## Git

采用 Trunk-Based Development 风格，以 `main` 作为唯一长期主线。

`main` 应保持：

```text
buildable
testable
integratable
```

理想情况下可发布，但：

```text
merge != release
```

未准备开放的功能优先通过 feature flag、internal implementation 或 unexposed API 提前集成，而不是维护长期 feature branch。

### Commit

推荐：

```text
<subsystem>: <imperative description>
```

例如：

```text
scheduler: avoid scanning inactive requests
attention: handle empty sequences
```

commit message 应 concise、specific、imperative。

当原因或 trade-off 不明显时，在 body 中说明 `why`。

### Branch & PR

从最新 `main` 创建短期分支：

```text
feat/...
fix/...
refactor/...
```

生命周期尽量控制在数小时到几天。

大型需求拆成多个可独立合入的 logical change。

个人独占分支同步：

```bash
git fetch origin
git rebase origin/main
```

不要 rebase 已被多人依赖的公共历史。

一个 PR 应代表：

```text
one clear logical change
```

PR description 说明：

```text
problem
purpose
approach
important decisions / trade-offs
```

合入前通常要求：

- CI 通过
- Code Review 通过
- 与最新 `main` 无冲突
- 没有无关修改

默认使用 squash merge：

```text
1 PR
=
1 logical change
=
1 commit on main
```

合并后删除无用分支。

## Documentation

文档是代码的辅助，不是代码的替代。

默认维护：

```text
README.md
```

说明项目简介、安装、使用、开发方式、当前状态和重要限制。

复杂设计放入：

```text
docs/
```

架构统一放入：

```text
docs/architecture/
```

文档优先记录代码无法直接表达的：

```text
why
constraints
trade-offs
operational knowledge
historical decisions
```

如果代码已经能够清楚表达实现，不要重复写文档。

## CI/CD

CI 的目标是缩短反馈周期，并阻止明显错误进入主线。

不要为了“拥有 CI”建设复杂 CI。

优先检查：

```text
format
lint
type check
test
build
```

如果合适，提供统一入口：

```text
make check
just check
task check
scripts/check
```

已有工具链和 CI 时优先维护现有方案。

没有 remote repository 时只维护本地验证；存在 remote 时先检查现有 CI，没有明确需求时不主动增加复杂远程 CI。

CI 应尽量：

```text
fast
deterministic
reproducible
relevant
```

避免 slow、flaky、duplicated 或 low-value 任务。

默认手动发布。只有明确需要时才增加 CD。

## Coding

编码优先保证：

```text
correctness
clarity
simplicity
maintainability
observability of failure
```

### Simplicity

简单直接的实现通常优于 premature framework。

少量、局部、尚未稳定的重复可以接受。只有多个调用方真正共享稳定语义时再抽象。

优先：

```text
duplication
```

而不是：

```text
wrong abstraction
```

修改尽量局部化，不要因为修改一个函数而顺手重新设计整个 subsystem。

### Types & Invariants

尽量让类型表达真实约束，但不要为了类型技巧制造复杂泛型体系。

重要不变量优先通过：

```text
type system
assertion
validation
test
```

表达。

理论上不允许出现的状态不要默默兼容。

### Error Handling

不要擅自吞掉错误或制造假成功。

除非产品语义明确要求，否则避免：

```text
silent fallback
arbitrary default
ignore exception
hide error and continue
fake success
```

违反预期状态时应明确：

```text
return / raise error
propagate exception
assert invariant
```

错误信息应包含定位问题所需的上下文。

### Dependency

优先：

```text
standard library
existing project dependencies
```

增加 dependency 前确认：

```text
existing tools are insufficient
dependency provides meaningful value
dependency is maintained
cost is acceptable
```

不要为了少量辅助代码引入大型依赖。

### Comments & Refactoring

注释优先解释：

```text
why
constraint
non-obvious behavior
dangerous assumption
external requirement
```

不要重复代码本身。

当前范围内可以持续重构，但必须：

```text
behavior preserved
scope controlled
validation available
```

大型或无关重构应独立处理。

### Performance

不要根据直觉优化。

优先：

```text
measure
→ identify bottleneck
→ optimize
→ measure again
```

性能优化必须同时保证正确性。

### Long-Running Jobs

长时间运行并持续产生结果的任务应根据需要支持：

```text
checkpoint
processed index
completed IDs
intermediate output
metadata
```

恢复时明确区分 completed、incomplete 和 invalid 状态，不要猜测进度。

## Toolchain

优先使用现代、稳定、维护良好的工具链，并遵循项目已有选择，例如：

1. Python：uv、pytest、ruff、basedpyright
1. rust：cargo、clippy、fmt
1. Typescript：Node LTS、Vite
1. GPU：Triton

## Definition of Done

一个修改通常只有在以下条件满足后才算完成：

```text
requested behavior implemented
relevant behavior verified
errors handled explicitly
no unnecessary complexity
tests updated when valuable
relevant checks pass
documentation updated when necessary
no unrelated changes
cleanly integratable into main
```

不是所有任务都必须增加测试、文档或架构图。只做真正提高正确性、反馈速度和长期可维护性的工作。
