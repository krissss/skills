---
name: git-commit
description: 创建符合规范的 git 提交消息。优先遵循项目现有提交规范，支持 Conventional Commits 格式。使用场景：用户要求创建提交、编写提交消息
---

# Git 提交消息

创建清晰、规范的 git 提交消息。优先遵循项目现有风格，其次参考 Conventional Commits 标准。

## 执行流程

### 步骤 1：确定项目规范（首次）

仅在首次使用时执行，缓存结果供后续复用。并行收集以下信息：

```bash
git log -5 --pretty=format:"%s"
git branch --show-current
```

同时检查项目根目录是否存在 commitlint 配置（`.commitlintrc.*`、`commitlint.config.*`、`package.json` 中的 `"commitlint"` 字段）。

#### 确定提交格式规范

按优先级取第一个匹配：

1. **commitlint 配置**：找到则严格按其规则生成，提取 `extends`（预设）、`parserPreset`（解析模式）、`rules`（type-enum、scope-enum、header-max-length 等）
2. **提交历史风格**：从最近 5 条提交推断类型名称（`feat`/`feature`）、语言（中文/英文）、issue 引用位置（subject 中/footer 中）
3. **Conventional Commits**：以上均无明确规范时使用默认标准

#### 提交类型

优先使用项目已有类型。无明确类型时参考：

| 类型 | 说明 |
|------|------|
| `feat` / `feature` | 新功能 |
| `fix` / `bugfix` | Bug 修复 |
| `docs` | 文档变更 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 重构（功能不变） |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具链 |

#### 提取分支关联的 Issue

从当前分支名中提取 issue 编号：

- `feature/#1254` → `#1254`
- `fix/123-login-blank` → `#123`
- `feat/new-feature-456` → `#456`
- `issue/789` → `#789`
- `feature/PROJ-123-desc` → `#PROJ-123`

解析到 issue 编号时，按上述确定的引用风格放置（subject 中或 footer 中）。

### 步骤 2：识别变更内容

```bash
git status --short
git diff --stat
```

#### 判断标准

**属于同一模块（一起提交）**：
- 同一功能的不同部分（API、类型、工具函数）
- 功能开发 + 相关文档/配置/依赖

**不搭界（分开提交）**：
- 不同业务模块的变更
- 代码 + 部署/CI 配置

#### 处理逻辑

**所有变更属于同一模块**：直接提交。

**大部分属于同一模块，少量不搭界**：

```
主要模块：用户模块
不相关变更（建议暂不提交）：
- src/api/orders.ts (订单模块)

跳过不相关内容，仅提交用户模块相关变更？(y/n)
```

**多个模块变更相当**：

```
用户模块：70行 | 订单模块：90行
建议先提交变更较多的模块，是否仅提交订单模块？(y/n/all)
```

### 步骤 3：检查是否需要合并提交

```bash
git log @{u}..HEAD --oneline 2>/dev/null
```

仅在有领先远程的本地提交时判断。合并条件：同一类型 + 相同模块文件、同一 bug 的修复、文档连续更新。其他情况不合并。

### 步骤 4：生成提交消息

基于项目规范和变更内容生成消息：

```
<type>(<scope>): <subject>

<body>

<footer>
```

**必需**：`type` + `subject`（50-72 字符）
**可选**：`scope`、`body`、`footer`

#### Subject 规则

- 祈使句：`add` 而非 `added`
- 英文首字母小写，中文正常大小写
- 句尾不加标点

#### Body 规则

- 解释做了什么以及为什么
- 每行限制 72 字符
- 描述变更的原因和影响，不要仅罗列修改的文件列表

#### Footer 规则

```
BREAKING CHANGE: API endpoints now require authentication
Closes #123
Refs #456
```

#### Scope 使用规范

- 使用小写字母，不超过 15 字符
- 跨模块或不确定时省略 scope
- 从项目已有提交或 commitlint `scope-enum` 中获取可用值

#### 破坏性变更

两种标记方式（均为 Conventional Commits 标准）：

**方式 1：类型后加 `!`**

```
feat!: remove deprecated endpoints
feat(api)!: remove deprecated endpoints
```

**方式 2：Footer 中声明**

```
feat(api): remove deprecated endpoints

BREAKING CHANGE: v1 endpoints are no longer available.
Migration guide: docs/migration.md
```

## 注意事项

- 仅负责创建提交，不执行推送
- 不提交密码、密钥、token 等敏感信息
- body 应描述变更的原因和影响，不要仅罗列修改的文件列表
- 不要在提交消息中包含 `Co-Authored-By` 等元信息

## 示例

### 基础

```
feat: add dark mode support
fix: 修复登录超时问题
docs: 更新安装指南
```

### 带 Scope

```
feat(auth): 实现 OAuth2 登录
fix(ui): 修复移动端按钮对齐问题
```

### 带 Issue

```
feat(auth): #1254 实现 OAuth2 登录
fix(ui): #123 修复移动端按钮对齐问题
```

### 带 Body

```
feat(api): add pagination support

Implement pagination for list endpoints:
- Add `page` and `limit` query parameters
- Return total count and pagination metadata

Closes #42
```
