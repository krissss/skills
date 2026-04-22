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

## Git Submodule

`agentskills-source/` 是 [agentskills/agentskills](https://github.com/agentskills/agentskills) 的 submodule，包含标准定义文档。克隆后需 `git submodule update --init`。
