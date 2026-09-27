## Architecture

少维护、按需补充，不要把画图体系本身变成负担。

C4 模型包含四个核心抽象层级：

1. System Context：这个系统是谁在用（user、admin），以及和哪些外部系统交互（payment、email）？
1. Container：System 由哪些可执行或可运行的主要单元组成？它们之间如何通信，主要技术栈是什么？
1. Component：Container 内部由哪些具有明确职责和接口的构件组成？
1. Code：具体的代码结构。

实际使用中，通常只长期维护 C1 和 C2；只为真正重要、复杂的 Container 补充 C3；C4 变化太快，通常直接以代码本身为准。

C4 还提供一些按需使用的视图：

1. Dynamic Diagram：某个 use case 中，各架构元素运行时如何交互？
1. Deployment Diagram：系统实际部署在哪里，以及软件单元与 VM、K8S、DB、网络等基础设施如何对应？
1. System Landscape Diagram：当组织中存在多个系统时，展示当前系统在整体系统版图中的位置和关系。

下面这些不属于 C4，但可以在需要时补充，用来解决具体问题：

1. State Machine Diagram：描述状态及状态转换，适合具有明显生命周期的对象、任务、订单、协议等。
1. Entity–Relationship Diagram：描述数据实体、属性及关系，适合数据库和领域数据模型。
1. Flowchart：描述复杂算法或业务逻辑中的控制流。
1. Data Flow Diagram：描述数据从哪里来、经过什么处理、最终流向哪里。

这些架构和设计文档统一放在项目的`docs/architecture/`目录下。

## Test

在项目设计阶段和开发初期，不应该过早围绕测试来设计系统，否则容易导致过度拆分、降低迭代速度，并增加维护负担。

当软件初见雏形、设计基本稳定、主要流程已经跑通并能看到结果后，再逐步建立测试体系。测试应围绕稳定的外部行为和关键不变量，而不是实现细节或覆盖率数字。

实际工程中，应优先选择快速、稳定、维护成本低的测试：

1. 纯逻辑和算法优先使用 unit、property 或 differential test
1. 模块协作使用 integration test，E2E 只覆盖关键路径
1. 尽量少用 mock，只隔离难以控制的外部依赖或异常场景
1. 修复 bug 或行为已经明确时适合 test-first；探索性开发和性能优化不必强制 TDD

核心原则可以概括为：测试稳定的行为和重要的不变量，而不是实现细节；把测试放在能以最低成本提供足够信心的最低层级。

## Git

任何项目接手后都应该检查是否初始化了 git，如果没有，则需要主动初始化，以项目当前状态作为 baseline 进行后续开发，方便代码回滚与版本管理。

采用 Trunk-Based Development 风格：以`main`作为唯一长期主线，开发工作通过短生命周期分支完成，并通过 Pull Request、CI 和 Code Review 合入主线。

### Commit Message

长期历史中的 commit 推荐采用：

```text
<subsystem>: <imperative description>
```

例如：

```text
kv-cache: compact fragmented blocks
scheduler: avoid scanning inactive requests
attention: handle empty sequences
cuda: fuse rotary embedding into attention kernel
docs: explain paged cache layout
```

优先写出受影响的模块，因为维护者通常更关心“改了哪里、改了什么”，而不是对修改进行抽象分类。描述应简洁、具体，并使用动作形式。如果修改原因、约束或设计决策不明显，应在 commit body 中说明为什么这样修改，而不是重复代码做了什么。

### 分支

`main`应始终保持可构建、可测试，理想情况下可直接发布。开发新功能或修复问题时，从最新的`main`创建短期分支：

```text
feat/kv-cache-packing
fix/empty-sequence
refactor/scheduler
```

分支应尽量保持短生命周期，一般控制在几小时到几天。大型功能应拆成多个可独立合入的小改动，必要时通过 feature flag 隐藏未完成功能。

除需要长期维护多个发布版本外，不建议使用`develop`、`release`等长期分支构成复杂的 Git Flow。

### 同步主线

个人独占的开发分支优先使用 rebase：

```bash
git fetch origin
git rebase origin/main
```

这样可以避免为了同步`main`产生无意义的 merge commit。不要 rebase 已经被多人依赖的公共历史。多人共享分支应谨慎重写历史。

### Pull Request

在分支建立后，就应该创建 Draft PR，后续在工作过程中持续提交并推送更改，同时维护 PR description，等真正准备好 review 时，再把 Draft 标记为 Ready for review。

PR 是代码审查和协作的主要单位，branch 只是临时工作空间。每个 PR 应表示一个清晰、独立的逻辑修改，并尽量保持较小规模。合入前通常要求：

- CI 通过
- Code Review 通过
- 与最新`main`不存在冲突
- PR 描述说明修改目的和关键设计决策

合并时使用 squash merge，保证：1 PR = 1 logical change = 1 commit on main。开发分支中的`WIP, fix test, address review, lint`等临时 commit 不需要进入长期历史。合并结束后，清理本地的相关分支。

## 文档

维护 README 文档来说明当前项目的简介、使用指南、开发状态、后续计划，并持续维护。

## CI/CD

在没有 remote 仓库的情况下，只维护本地 CI。

如果存在 remote 仓库，检查项目是否已设置 Github Action 等远程 CI，如果有，则维护，如果没有，则不维护，只在后续我们主动提出添加远程 CI 后才初始化并维护。

CD 风险较大，一般不维护，由我们手动发布。

## Coding

在编码时，需要尽可能遵循以下准则：

1. Type annotation：尽可能标注类型，提前发现代码中的问题
1. Simple and Stupid：简明，不引入复杂的抽象层
1. 错误处理：不能擅自处理错误，包括但不限于设定默认值、隐藏错误信息继续运行等。与代码意图不符的行为都应该直接抛出错误，帮助我们继续改进代码以处理相关情况。
1. 持久化与断点续行：对于需要长时间运行并且持续产出的脚本，需要加入中断后可继续当前结果运行的机制，减少不必要的重复计算

并且选择尽可能现代且稳定的语言以及工具链：

1. Python：uv、ruff、basedpyright
1. Javascript：Typescript、Node LTS、pnpm
1. Rust
1. Triton
