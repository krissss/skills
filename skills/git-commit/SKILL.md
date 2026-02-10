---
name: git-commit
description: 创建符合规范的 git 提交消息。优先遵循项目现有提交规范，支持 Conventional Commits 格式。使用场景：用户要求创建提交、编写提交消息
---

# Git 提交消息

## 功能概述

创建清晰、规范的 git 提交消息。优先遵循项目现有的提交历史和格式规范，其次参考 Conventional Commits 标准。确保提交消息简洁、一致且易于理解。

## 快速检查流程

### 步骤 1：快速确定项目规范（首次使用）

仅在首次使用或项目规范未知时执行：

```bash
# 查看最近 5 条提交即可
git log -5 --pretty=format:"%s"
```

**快速判断**：
- 类型名称：`feat` 或 `feature`、`fix` 或 `bugfix`
- 语言：中文或英文
- Issue 引用：subject 中或 footer 中

**缓存判断结果**，后续提交无需重复分析。

### 步骤 2：识别变更内容

```bash
# 查看当前变更
git diff --stat
```

判断变更是否属于同一模块：
- 如无不相关内容，直接进入步骤 3
- 如有不相关内容，参考"智能识别变更内容"章节的处理方法

### 步骤 3：检查是否需要合并提交

```bash
git status
git log @{u}..HEAD --oneline 2>/dev/null
```

- 如无领先提交，直接进入步骤 4
- 如有领先提交，参考"合并相似提交"章节的判断方法

### 步骤 4：快速生成提交消息

基于缓存的规范和变更内容快速生成消息，无需详细分析。

## 优先遵循项目现有规范

### 检查项目提交风格

```bash
# 仅查看最近 5 条提交
git log -5 --pretty=format:"%s"
```

### 确定项目规范

- **类型名称**：`feat` vs `feature`、`fix` vs `bugfix`
- **Issue 引用**：subject 中（`feat: #123 xxx`）或 footer 中（`Closes #123`）
- **语言风格**：中文或英文
- **格式宽松度**：是否严格遵循某种规范

### 语言选择

统计最近提交，中文占多数用中文，否则用英文。

### 遵循原则

- 项目有明确规范 → 严格遵循
- 项目无明确规范 → 模仿现有风格
- 项目无明显风格 → 使用 Conventional Commits 标准

## 提交消息格式

### Conventional Commits 标准

```
<type>(<scope>): <subject>

<body>

<footer>
```

**必需部分**：
- `type`: 提交类型
- `subject`: 简短描述（50-72 字符）

**可选部分**：
- `scope`: 影响范围
- `body`: 详细描述
- `footer`: 破坏性变更、引用等

### 提交类型（type）

**优先使用项目类型**。无明确类型时参考：

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` / `feature` | 新功能 | feat: 添加用户认证 |
| `fix` / `bugfix` | Bug 修复 | fix: 修复登录超时 |
| `docs` | 文档变更 | docs: 更新 API 文档 |
| `style` | 代码格式 | style: 统一代码缩进 |
| `refactor` | 重构 | refactor: 提取公共方法 |
| `perf` | 性能优化 | perf: 优化查询性能 |
| `test` | 测试相关 | test: 添加单元测试 |
| `chore` | 构建/工具链 | chore: 更新依赖版本 |

### Subject 规则

- 使用祈使句（现在时态）：`add` 而不是 `added` 或 `adds`
- 首字母小写（英文）或正常大小写（中文）
- 句尾不加标点
- 限制在 50-72 个字符
- 清晰描述做了什么

### Body 规则

- 解释做了什么以及为什么做
- 每行限制在 72 个字符
- 使用祈使句
- 提供足够的上下文

### Footer 规则

**破坏性变更**：
```
BREAKING CHANGE: API endpoints now require authentication
```

**引用 Issue/PR**：
```
Closes #123
Refs #456
```

## Scope 使用规范

Scope 指定提交的影响范围。

**常用 Scope**：

| 项目类型 | Scope 示例 |
|---------|-----------|
| Web 应用 | `api`, `ui`, `auth`, `db` |
| 库/框架 | `core`, `utils`, `types` |
| 移动应用 | `ios`, `android`, `shared` |
| DevOps | `ci`, `docker`, `deploy` |

**格式规则**：
- 使用小写字母
- 不超过 10-15 个字符
- 不确定时省略 scope

## 智能识别变更内容

### 分析原则

1. **识别主要模块**：分析所有变更文件，找出大部分内容所属的模块/业务
2. **识别不搭界内容**：找出与主要模块完全不相关的变更
3. **建议提交策略**：主要模块内容提交，不搭界内容暂不提交

### 判断标准

**属于同一模块/业务（建议一起提交）**：
- 同一功能的不同部分（API、类型、工具函数）
- 功能开发 + 相关文档
- 功能开发 + 相关配置
- 功能开发 + 依赖更新

**完全不搭界（建议暂不提交）**：
- 不同业务模块的变更（用户模块 + 订单模块）
- 代码 + 部署配置文件
- 代码 + CI/CD 配置
- 代码 + .gitignore 等配置

### 处理逻辑

**情况 1：所有变更属于同一模块**

直接提交，无需提示。

**情况 2：大部分变更属于同一模块，少量不搭界**

```
变更内容：
- src/api/users.ts (用户模块)
- src/types/user.ts (用户模块)
- src/api/orders.ts (订单模块，不搭界)

主要模块：用户模块

不相关变更（建议暂不提交）：
- src/api/orders.ts (订单模块，不搭界)

跳过不相关内容，仅提交用户模块相关变更？(y/n)
```

**情况 3：多个模块变更相当**

```
变更内容：
- src/api/users.ts (用户模块，50行)
- src/types/user.ts (用户模块，20行)
- src/api/orders.ts (订单模块，60行)
- src/types/order.ts (订单模块，30行)

用户模块：70行
订单模块：90行

订单模块变更更多，建议提交订单模块相关：
- src/api/orders.ts
- src/types/order.ts

是否仅提交订单模块？(y/n)
或选择提交所有？(all)
```

### 处理方法

```bash
# 仅暂存主要模块相关文件
git add src/api/users.ts src/types/user.ts
git commit -m "feat(api): 添加用户接口"

# 不搭界的文件不暂存，留待后续处理
```

## 合并相似提交

### 前置检查

**仅在有领先提交时执行合并判断**：

```bash
# 检查是否有领先提交
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")

if [ "$AHEAD" -eq 0 ]; then
  # 无领先提交，直接创建新提交
  echo "本地与远程同步，直接创建新提交"
else
  # 有领先提交，进行合并判断
  echo "本地有 $AHEAD 个领先提交，检查是否需要合并"
fi
```

### 快速相似度判断

**仅需查看上次提交消息和当前变更**：

```bash
# 获取上次提交
LAST_COMMIT_MSG=$(git log -1 --pretty=format:"%s")

# 查看当前变更
git diff --stat
```

**判断标准**：

| 条件 | 操作 |
|------|------|
| 同一类型 + 相同模块文件 | 询问是否合并 |
| 同一 bug 的修复 | 询问是否合并 |
| 文档连续更新 | 询问是否合并 |
| 其他情况 | 不合并 |

### 合并方法

```bash
# 暂存当前变更
git add <files>

# 合并到上一次提交
git commit --amend --no-edit

# 或更新提交消息
git commit --amend -m "更新后的提交消息"
```

## 实际示例

### 基础示例

**英文**：
```
feat: add dark mode support
fix: resolve login timeout issue
docs: update README with new installation steps
```

**中文**：
```
feat: 添加深色模式支持
fix: 修复登录超时问题
docs: 更新安装指南
```

### 带 Scope 的示例

```
feat(auth): implement OAuth2 login
fix(ui): correct button alignment on mobile
refactor(db): optimize user query performance
```

**中文示例**：
```
feat(auth): 实现 OAuth2 登录
fix(ui): 修复移动端按钮对齐问题
refactor(db): 优化用户查询性能
```

### 带 Body 的示例

```
feat(api): add pagination support

Implement pagination for list endpoints:
- Add `page` and `limit` query parameters
- Return total count and pagination metadata
- Update documentation with examples

Closes #42
```

```
fix(auth): resolve token expiration issue

The JWT token expiration was not being checked
correctly, allowing expired tokens to be used.
Added proper validation middleware.

Fixes #128
```

### 破坏性变更示例

```
feat(api): remove deprecated endpoints

Remove v1 endpoints in favor of v2:
- DELETE /api/v1/users
- DELETE /api/v1/posts

BREAKING CHANGE: v1 endpoints are no longer available.
Please migrate to v2 endpoints.

Migration guide: docs/migration.md
```

```
feat(auth): require email verification

All new users must verify their email before
accessing the platform.

BREAKING CHANGE: Email verification is now mandatory.
Existing users are grandfathered in.
```

## 常见问题

### 问题：提交消息太长

**解决方案**：简化描述，将详细信息放入 body。

```
feat: add comprehensive user authentication system with OAuth2 support and token management

↓

feat: add user authentication

Implement OAuth2 login and token management system
```

### 问题：类型选择困难

**快速决策**：
```
新功能 → feat
修复 bug → fix
重构（功能不变） → refactor
性能优化 → perf
文档 → docs
格式调整 → style
测试 → test
其他 → chore
```

### 问题：Scope 不确定

**指导原则**：
- 跨模块变更 → 省略 scope
- 单一模块变更 → 使用模块名作为 scope
- 不确定 → 省略 scope

## 注意事项

- **仅本地操作**：此技能仅负责创建提交，不执行任何推送
- **保持原子性**：一个提交只做一件事
- **提交历史清晰**：能够重现开发过程
- **避免敏感信息**：不提交密码、密钥、token
- **遵循项目规范**：项目有规范时严格遵循
