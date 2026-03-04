---
name: git-commit
description: 创建符合规范的 git 提交消息。优先遵循项目现有提交规范，支持 Conventional Commits 格式。使用场景：用户要求创建提交、编写提交消息
---

# Git 提交消息

创建清晰、规范的 git 提交消息。优先遵循项目现有风格，其次参考 Conventional Commits 标准。

详细格式规范和示例见 [references/REFERENCE.md](references/REFERENCE.md)。

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

判断变更是否属于同一模块。如有不相关内容，建议拆分提交（仅暂存主要模块文件）。详见 [REFERENCE.md#智能识别变更内容](references/REFERENCE.md#智能识别变更内容)。

### 步骤 3：检查是否需要合并提交

```bash
git log @{u}..HEAD --oneline 2>/dev/null
```

仅在有领先远程的本地提交时判断：同类型 + 同模块文件 → 询问是否 amend。详见 [REFERENCE.md#合并相似提交](references/REFERENCE.md#合并相似提交)。

### 步骤 4：生成提交消息

基于项目规范和变更内容生成消息：

```
<type>(<scope>): <subject>
```

- `type` + `subject` 必需，`scope`/`body`/`footer` 可选
- subject 限制 50-72 字符，祈使句，句尾无标点
- 一个提交只做一件事

## 注意事项

- 仅负责创建提交，不执行推送
- 不提交密码、密钥、token 等敏感信息
- body 应描述变更的原因和影响，不要仅罗列修改的文件列表
- 不要在提交消息中包含 `Co-Authored-By` 等元信息
