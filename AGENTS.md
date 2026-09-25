## C4

软件开发中的C4模型静态图：

1. System Context：这个系统是谁在用（用户、admin）、和哪些外部系统交互（payment、email）？
1. Container：System由哪些可执行或可运行的主要单元组成？它们之间如何通信以及主要的技术栈？
1. Component：Container内部由哪些具有明确职责和接口的内部构件组成？
1. Code：具体的代码结构？

实际使用中，我们通常维护C1和C2，只对于某些重要的Container维护C3，C4由于变化太快，不手动维护，直接使用代码表示

C4还推荐我们使用以下几种图来更好的设计：

1. Sequence Diagram：具体流程中谁先做什么，然后谁又做了什么？
2. Deployment Diagram：实际部署系统时跑在哪里（VM、K8S、DB、firewall等等）？
3. System Landscape Diagram：如果在项目外还存在很多系统，当前项目的位置？

此外，我们还常用：

1. State Machine Diagram：对象所处的状态，以及如何随时间转换？
1. Entity–Relationship Diagram：侧重数据结构，有哪些实体、实体有哪些属性、实体之间是什么关系？
1. Flowchart：复杂算法或业务流程的控制逻辑？
1. Data Flow Diagram：数据从哪来，经过什么处理，流向哪里？

这些设计文档应该放在项目的`docs/c4/`目录下。

## Test-driven development

我们使用测试驱动的开发：先通过测试描述你希望代码具有什么行为，再写最少的实现让这个行为成立，最后在测试保护下重构。

TDD可以迫使我们站在调用者的角度思考，怎么去设计接口，同时为了实现良好的测试，也迫使我们设计低耦合的代码（同时也要注意，大量依赖Mock可能会得到很脆弱的设计）。

TDD的流程可以分为三步：

1. Red：写测试，这时由于没有代码实现所以无法通过
1. Green：写足够少的代码（不是低质量代码），通过测试
1. Refactor：再考虑代码结构、命名、抽象、错误处理等问题，在测试的保护下完成重构。

TDD可以和C4模型结合使用：

1. C4: Unit tests
1. C3: Componet tests
1. C2: Integration tests
1. C1: E2E tests

对于C1，我们一般用自然语言描述behavior specifications，配合Sequence Diagram。然后C2描述behavior/protocol specifications，并且可以写一些测试。然后深入到C3/C4配合TDD进行实现，再回到C2补全测试，最后回到C1补上E2E测试。

## Git

任何项目接手后都应该检查是否初始化了git，如果没有，则需要主动初始化，以项目当前状态作为baseline进行后续开发，方便代码回滚与版本管理。

采用Trunk-Based Development风格：以`main`作为唯一长期主线，开发工作通过短生命周期分支完成，并通过Pull Request、CI和Code Review合入主线。

### Commit Message

长期历史中的commit推荐采用：

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

优先写出受影响的模块，因为维护者通常更关心“改了哪里、改了什么”，而不是对修改进行抽象分类。

描述应简洁、具体，并使用动作形式。

如果修改原因、约束或设计决策不明显，应在commit body中说明为什么这样修改，而不是重复代码做了什么。

### 分支

`main`应始终保持可构建、可测试，理想情况下可直接发布。

开发新功能或修复问题时，从最新的`main`创建短期分支：

```text
feat/kv-cache-packing
fix/empty-sequence
refactor/scheduler
```

分支应尽量保持短生命周期，一般控制在几小时到几天。大型功能应拆成多个可独立合入的小改动，必要时通过 feature flag 隐藏未完成功能。

除需要长期维护多个发布版本外，不建议使用`develop`、`release`等长期分支构成复杂的 Git Flow。

### 同步主线

个人独占的开发分支优先使用rebase：

```bash
git fetch origin
git rebase origin/main
```

这样可以避免为了同步`main`产生无意义的merge commit。

不要rebase已经被多人依赖的公共历史。多人共享分支应谨慎重写历史。

### Pull Request

每个PR应表示一个清晰、独立的逻辑修改，并尽量保持较小规模。

合入前通常要求：

- CI通过；
- Code Review通过；
- 与最新`main`不存在冲突；
- PR描述说明修改目的和关键设计决策。

PR是代码审查和协作的主要单位，branch只是临时工作空间。

如果仅在本地开发，则可在分支任务完成后，直接在本地进行squash merge。

### 合并策略

一般项目推荐默认使用Squash Merge：

```text
1 PR = 1 logical change = 1 commit on main
```

开发分支中的：

```text
WIP
fix test
address review
lint
```

等临时commit不需要进入长期历史，commit信息中要说明merge的是哪个分支，例如：

```text
merge from <branch name>: <subsystem>: <imperative description>
```

合并结束后，清理远程和本地的相关分支，以及下文提到的文档。

## 文档

我们需要编写简明扼要的README文档来说明当前项目的简介、开发状态、后续计划，并持续维护。

对于每个分支，也需要维护相关文档，说明这个分支的开发意图、进度、后续计划。分支文档以分支名命名，放置在项目的`docs/branch/`目录下，在分支被squash merge后，应清理掉相关的分支文档。

## CI/CD

在没有remote仓库的情况下，只维护本地CI

如果存在remote仓库，检查项目是否已设置Github Action等远程CI，如果有，则维护，如果没有，则不维护，只在后续我们主动提出添加远程CI后才初始化并维护。

CD风险较大，一般不维护，由我们手动发布。

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
