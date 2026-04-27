---
name: install-skills-with-symbol
description: 将指定目录下的 skills 通过符号链接安装到目标目录。支持单 skill 目录和多 skill 父目录，自动校验 SKILL.md 存在性。使用场景：安装技能、链接 skills 到指定目录
---

# 通过软链安装 Skills

将指定来源的 skills 通过符号链接安装到目标目录，使 AI 工具能够发现和使用这些技能。

## 执行流程

### 步骤 1: 确认参数

需要两个参数：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| 来源目录 | 包含 skill 的目录（单 skill 或多 skill 父目录） | 当前仓库的 `skills/` 目录 |
| 目标目录 | 软链安装位置 | `~/.agents/skills` |

如果用户未指定，使用默认值并告知。

### 步骤 2: 执行安装脚本

运行 [scripts/install.sh](scripts/install.sh)：

```bash
bash scripts/install.sh <来源目录> <目标目录>
```

脚本会自动识别来源类型：
- 来源目录下直接有 `SKILL.md` → 单 skill，仅链接这一个
- 来源目录下有多个子目录含 `SKILL.md` → 多 skill，逐个链接
- 子目录没有 `SKILL.md` → 报错跳过

### 步骤 3: 展示结果

脚本输出每个 skill 的安装状态和最终目录。

安装成功后告知用户：

```
✅ Skills 已安装到 ~/.agents

已安装 N 个技能：
- git-commit
- git-release
- ...

❌ 跳过 1 个无效目录：
- some-dir（未找到 SKILL.md）
```

## 卸载

用户要求卸载时：

```bash
bash scripts/install.sh --uninstall <来源目录> <目标目录>
```

仅删除来自该来源目录的软链，不影响目标目录中其他软链或真实目录。

## 使用示例

- `安装 skills`
- `把当前仓库的 skills 安装到 ~/.claude/skills`
- `把 ~/projects/my-skills 目录下的技能安装到 ~/.agents`
- `安装 ~/projects/my-custom-skill 这个技能`
- `卸载 skills`
