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

### SKILL.md 拆分原则

**核心原则：主流程自包含，低频场景才拆分。**

AI 看完 SKILL.md 就能处理 80%+ 的常见任务，不需要跳转 reference。

#### 什么放 SKILL.md（主流程）

- **认证简要流程**：缓存检查 → 有效直接用 → 无效则跳 reference 获取
- **核心 API 调用命令**：增删改查的主要接口
- **输出展示模板**：告诉 AI 结果应该怎么呈现给用户
- **关键判断逻辑**：每个主流程分支前必须检查的条件
- **注意事项**：踩坑记录、单位换算、必填字段等

#### 什么拆到 references/（低频场景）

- **异常处理细节**：如认证过期后的完整重登录流程、降级方案
- **失败排查**：如某个操作失败后的逐层排查步骤
- **扩展模式**：如批量操作、高级筛选等非单条处理的场景
- **不常用的接口**：如归档、导入导出等辅助操作
- **完整字段表**：如 API 返回的所有可查询字段列表

#### 什么放到 scripts/

- **数据处理**：解析 API 返回的 JSON、格式化输出（CSV、表格）
- **重复逻辑**：每次都要执行的数据聚合、单位换算、格式转换

#### 判断标准

问自己：**"AI 处理最常见的任务时，需要打开这个文件吗？"**

- 每次都需要 → 放 SKILL.md
- 偶尔需要（< 20% 的场景）→ 放 references/
- 不确定 → 先放 SKILL.md，等文档膨胀后再考虑拆分

#### Shell 命令写法

避免使用 `$()` 和反引号命令替换（会触发 ShellEvasionGuardian）。改为分步指令：

```
# ❌ 避免
API_KEY=$(cat ~/.config/api_key)

# ✅ 改为分步
cat ~/.config/api_key
# 将输出值用于后续请求的认证头
```

## Git Submodule

`agentskills-source/` 是 [agentskills/agentskills](https://github.com/agentskills/agentskills) 的 submodule，包含标准定义文档。克隆后需 `git submodule update --init`。
