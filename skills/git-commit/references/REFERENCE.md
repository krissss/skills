# Git Commit 详细参考

## Conventional Commits 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

**必需**：`type` + `subject`（50-72 字符）
**可选**：`scope`、`body`、`footer`

### 提交类型

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

### Subject 规则

- 祈使句：`add` 而非 `added`
- 英文首字母小写，中文正常大小写
- 句尾不加标点

### Body 规则

- 解释做了什么以及为什么
- 每行限制 72 字符
- 描述变更的原因和影响，不要仅罗列修改的文件列表
- 不包含 `Co-Authored-By` 等元信息

### Footer 规则

```
BREAKING CHANGE: API endpoints now require authentication
Closes #123
Refs #456
```

## Scope 使用规范

- 使用小写字母，不超过 15 字符
- 跨模块或不确定时省略 scope
- 从项目已有提交或 commitlint `scope-enum` 中获取可用值

## 智能识别变更内容

### 判断标准

**属于同一模块（一起提交）**：
- 同一功能的不同部分（API、类型、工具函数）
- 功能开发 + 相关文档/配置/依赖

**不搭界（分开提交）**：
- 不同业务模块的变更
- 代码 + 部署/CI 配置

### 处理逻辑

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

## 合并相似提交

仅在有领先远程的本地提交时判断。

```bash
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
```

**合并条件**：同一类型 + 相同模块文件、同一 bug 的修复、文档连续更新。其他情况不合并。

```bash
git add <files>
git commit --amend --no-edit
```

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

### 破坏性变更

```
feat(api): remove deprecated endpoints

Remove v1 endpoints in favor of v2.

BREAKING CHANGE: v1 endpoints are no longer available.
Migration guide: docs/migration.md
```
