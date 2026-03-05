# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Skill 规范要点

每个 skill 是 `skills/` 下的一个目录，必须包含 `SKILL.md` 文件。完整规范见 `agentskills-source/docs/specification.mdx`。

### SKILL.md 结构

```yaml
---
name: skill-name          # 必需，小写字母+数字+连字符，1-64字符，必须与目录名一致
description: 描述内容       # 必需，说明功能和使用场景，最多1024字符
---
```

Body 部分为 Markdown 格式的技能指令，无格式限制。建议控制在 500 行以内，详细内容拆分到 `references/`、`scripts/`、`assets/` 子目录。

### name 命名规则

- 仅允许小写字母、数字、连字符
- 不能以连字符开头或结尾，不能有连续连字符

## 现有技能

- `git-commit`: 规范化 git 提交消息
- `git-release`: 自动化 GitHub/GitLab/Gitea 发布流程（CHANGELOG + 语义化版本 + Release）
- `git-issue-solver`: 自动化处理 GitHub/GitLab/Gitea Issue（列表/选择/分支/实现/提交）
- `git-issue-report`: 在 GitHub/GitLab/Gitea 上创建格式规范的 Issue（优先使用仓库模板，支持 Bug 报告/功能请求/改进建议）
- `tauri-create`: Tauri 项目创建向导
- `tauri-best-practices`: Tauri 开发最佳实践

## 技能间依赖

- `git-issue-solver` 在提交阶段调用 `git-commit` 技能
- `git-release` 依赖 Conventional Commits 格式的提交历史

## Git Submodule

`agentskills-source/` 是 [agentskills/agentskills](https://github.com/agentskills/agentskills) 的 submodule，包含标准定义文档。克隆后需 `git submodule update --init`。
