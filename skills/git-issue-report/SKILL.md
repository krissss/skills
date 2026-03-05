---
name: git-issue-report
description: 在 GitHub/GitLab 上创建格式规范的 Issue。优先使用仓库 Issue 模板，支持 Bug 报告、功能请求等类型，自动生成结构化描述。使用场景：用户要求提交 issue、报告 bug、提出功能需求
---

# Git Issue 创建（GitHub / GitLab）

在 GitHub/GitLab 上创建格式规范的 Issue，优先使用仓库已有的 Issue 模板，否则按内置类型生成结构化描述。

**默认行为**：用户直接调用本技能且未指定类型时，先检测仓库模板，有则展示模板列表，无则展示内置类型菜单。

模板格式、字段定义和平台 CLI 参考见 [references/REFERENCE.md](references/REFERENCE.md)。

## 执行流程

### 步骤 0: 验证 Git 平台

```bash
git remote get-url origin
```

解析 URL 判断平台：
- **GitHub**: `github.com` 域名 → 提取 `owner/repo`
- **GitLab**: `gitlab.com` 或自托管 GitLab 域名 → 提取 `owner/repo`
- **其他**: 通知用户此技能仅支持 GitHub/GitLab，询问是否继续

### 步骤 1: 检测仓库 Issue 模板

检查仓库中是否存在 Issue 模板（模板位置和解析规则见 [REFERENCE.md#仓库-issue-模板](references/REFERENCE.md#仓库-issue-模板)）：

```bash
ls .github/ISSUE_TEMPLATE/*.yml .github/ISSUE_TEMPLATE/*.yaml .github/ISSUE_TEMPLATE/*.md 2>/dev/null
ls .github/ISSUE_TEMPLATE.md 2>/dev/null
ls .gitlab/issue_templates/*.md 2>/dev/null
```

#### 发现仓库模板时

解析模板文件，展示列表供用户选择：

```
📂 检测到仓库 Issue 模板：
1. 🐛 Bug Report — 报告一个 bug
2. ✨ Feature Request — 提出新功能
3. 📝 自定义（不使用模板）

请选择 (1/2/3):
```

选择模板后，模板预设的 `labels`、`assignees` 自动应用，跳转到步骤 3。

#### 未发现仓库模板时

进入步骤 2。

### 步骤 2: 确定 Issue 类型（无仓库模板时）

如果用户已明确类型（如"报告一个 bug"），直接使用。否则提供选择菜单：

```
请选择 Issue 类型：
1. 🐛 Bug 报告
2. ✨ 功能请求
3. 🔧 改进建议
4. 📝 其他

请选择 (1/2/3/4):
```

### 步骤 3: 收集 Issue 信息

- **仓库模板**：按模板字段结构引导填写（YAML 表单按 `body` 逐项收集，Markdown 按标题分段填写）
- **内置类型**：按 [REFERENCE.md#内置-issue-模板](references/REFERENCE.md#内置-issue-模板) 中定义的必填/可选字段引导填写

如果用户已在对话中提供了部分信息，自动匹配到对应字段，仅询问缺失的必填项。

#### 需求完善与上下文辅助

适用于所有路径（仓库模板和内置类型）：

- **代码上下文辅助**：用户提到具体文件、函数或代码片段时，分析相关代码并自动补充到描述中
- **表述优化**：将口语化、模糊的描述改写为清晰、准确的技术表述
- **信息补全**：根据上下文推断并补充用户遗漏的关键信息（如复现条件、影响范围）
- **歧义消除**：发现描述存在多种理解时，主动向用户确认具体含义
- **结构化整理**：将零散的描述整理为有逻辑的段落，确保阅读者能快速理解问题或需求

### 步骤 4: 生成并预览 Issue

按仓库模板或内置模板格式生成 Issue 内容，展示预览供用户确认。用户可要求修改标题、正文、标签等，修改后重新预览。

预览格式示例见 [REFERENCE.md#预览格式](references/REFERENCE.md#预览格式)。

### 步骤 5: 创建 Issue

使用[平台 CLI 工具](references/REFERENCE.md#平台-cli-工具)创建 Issue。

可选参数：
- `--label`：添加标签（见 [REFERENCE.md#标签映射](references/REFERENCE.md#标签映射)）
- `--assignee`：指派给用户（仅在用户要求时添加）

创建成功后展示：

```
✅ Issue 已创建

#128 登录页面在 Safari 中无法正常显示
🔗 https://github.com/owner/repo/issues/128
🏷️ 标签: bug
```

**认证失败时**：提供格式化的 Issue 内容（Markdown），供用户在 Web UI 手动创建。

## 错误处理

| 场景 | 处理 |
|-----|------|
| CLI 未安装 | 提示安装 `gh`/`glab` |
| 认证失败 | 提示重新登录，提供 Markdown 内容供手动创建 |
| 无远程仓库 | 中止并提示配置 |
| 模板解析失败 | 提示模板格式异常，回退到内置类型流程 |
| 创建失败 | 展示错误信息，提供 Markdown 内容供手动创建 |

## 注意事项

- 不在 Issue 中包含敏感信息（密码、密钥、token 等）
- Issue 正文中的代码片段使用代码块包裹
- 标题保持简洁，控制在 80 字符以内

## 使用示例

- `帮我提一个 bug`
- `我想提一个功能请求：支持暗色模式`
- `这个函数有问题，帮我创建一个 issue`
- `报告一个 bug：用户注册时邮箱验证失败`
