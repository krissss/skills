# 参考资料

## 仓库 Issue 模板

### 模板文件位置

| 平台 | 路径 | 格式 |
|-----|------|------|
| GitHub | `.github/ISSUE_TEMPLATE/*.yml` / `*.yaml` | YAML 表单模板 |
| GitHub | `.github/ISSUE_TEMPLATE/*.md` | Markdown 模板 |
| GitHub | `.github/ISSUE_TEMPLATE.md`（单文件） | Markdown 模板 |
| GitLab | `.gitlab/issue_templates/*.md` | Markdown 模板 |
| Gitea | `.gitea/issue_template/*.md` | Markdown 模板 |

### GitHub YAML 表单模板结构

```yaml
name: Bug Report
description: 报告一个 bug
labels: ["bug"]
assignees: []
body:
  - type: input
    id: title
    attributes:
      label: 标题
    validations:
      required: true
  - type: textarea
    id: description
    attributes:
      label: 描述
      placeholder: 详细描述问题...
  - type: dropdown
    id: severity
    attributes:
      label: 严重程度
      options:
        - 低
        - 中
        - 高
```

支持的 `body` 类型：`input`、`textarea`、`dropdown`、`checkboxes`、`markdown`（纯展示）。

### GitHub/GitLab Markdown 模板结构

```markdown
---
name: Bug Report
about: 报告一个 bug
labels: bug
assignees: ''
---

## 描述
<!-- 详细描述问题 -->

## 复现步骤
1.
2.
```

解析规则：
- frontmatter 中提取 `name`、`about`/`description`、`labels`、`assignees`
- body 中的 `##` 标题作为字段分隔
- `<!-- ... -->` 注释作为字段提示

---

## 内置 Issue 模板

### Bug 报告

必填字段：标题、问题描述、复现步骤、期望行为、实际行为
可选字段：环境信息（OS、浏览器、语言版本等）、截图/日志

```markdown
## 问题描述

[简要描述问题]

## 复现步骤

1. [步骤 1]
2. [步骤 2]
3. ...

## 期望行为

[应该发生什么]

## 实际行为

[实际发生了什么]

## 环境信息

- OS: [操作系统]
- 版本: [软件/浏览器版本]
```

### 功能请求

必填字段：标题、功能描述、使用场景
可选字段：期望方案、替代方案

```markdown
## 功能描述

[描述想要的功能]

## 使用场景

[为什么需要这个功能，解决什么问题]

## 期望方案

[理想的实现方式]

## 替代方案

[是否考虑过其他方式]
```

### 改进建议

必填字段：标题、描述
可选字段：动机

```markdown
## 描述

[详细说明改进内容]

## 动机

[为什么需要这个改进]
```

### 其他

必填字段：标题、描述

```markdown
## 描述

[详细说明]
```

---

## 预览格式

### 使用仓库模板时

```
📋 Issue 预览（模板: Bug Report）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

标题: 登录页面在 Safari 中无法正常显示
标签: bug（来自模板）

---（正文）---
### Describe the bug
登录页面在 Safari 浏览器中布局错乱，输入框重叠。

### Steps to reproduce
1. 使用 Safari 17.0 打开登录页面
2. 观察表单布局

### Expected behavior
表单元素正常排列，与 Chrome 中一致。

### Environment
- OS: macOS 14.0
- Browser: Safari 17.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

确认创建？可修改内容后再提交。(y/n)
```

保留模板原有的标题层级和格式。

### 使用内置类型时

```
📋 Issue 预览
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

标题: 登录页面在 Safari 中无法正常显示
类型: Bug 报告
标签: bug

---（正文）---
## 问题描述
登录页面在 Safari 浏览器中布局错乱，输入框重叠。

## 复现步骤
1. 使用 Safari 17.0 打开登录页面
2. 观察表单布局

## 期望行为
表单元素正常排列，与 Chrome 中一致。

## 实际行为
用户名和密码输入框发生重叠，提交按钮不可见。

## 环境信息
- OS: macOS 14.0
- 浏览器: Safari 17.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

确认创建？可修改内容后再提交。(y/n)
```

---

## 标签映射

| Issue 类型 | 推荐标签 |
|-----------|---------|
| Bug 报告 | `bug` |
| 功能请求 | `enhancement` |
| 改进建议 | `enhancement` |
| 其他 | 不添加标签 |

> 标签仅在仓库中已存在对应标签时才添加。创建前使用 CLI 检查可用标签。

### 检查可用标签

```bash
# GitHub
gh label list

# GitLab
glab label list

# Gitea
tea labels list
```

---

## 平台 CLI 工具

### GitHub

```bash
gh issue create --title "..." --body "..." --label "bug"   # 创建 issue
gh issue create --title "..." --body "..." --assignee "@me" # 指派给自己
gh label list                                                # 列出标签
```

### GitLab

```bash
glab issue create --title "..." --description "..." --label "bug"   # 创建 issue
glab issue create --title "..." --description "..." --assignee "@me" # 指派给自己
glab label list                                                      # 列出标签
```

### Gitea

```bash
tea issues create --title "..." --body "..." --labels "bug"   # 创建 issue
tea labels list                                                # 列出标签
```
