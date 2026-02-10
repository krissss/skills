---
name: git-release
description: 自动化 GitHub/GitLab 发布流程。使用场景：发布新版本、创建版本标签、更新 CHANGELOG。自动分析 Git 提交、更新 CHANGELOG.md、确定语义化版本号、创建 Git 标签、推送到远程并创建 Release
---

# Git 自动发布（GitHub / GitLab）

## 功能概述

自动化 GitHub/GitLab Release 发布流程，遵循语义化版本（Semantic Versioning）规范。自动分析 Git 提交记录并更新 CHANGELOG.md，然后确定合适的版本号并完成发布。

## 发布流程

### 步骤 0: 验证 Git 平台

检查当前仓库的 Git 平台类型：

```bash
git remote get-url origin
```

解析并验证 URL 格式：

**GitHub**：
- HTTPS: `https://github.com/owner/repo.git`
- SSH: `git@github.com:owner/repo.git`
- 提取 `owner/repo` 用于后续创建 GitHub Release

**GitLab**：
- HTTPS: `https://gitlab.com/owner/repo.git` 或自托管 `https://gitlab.example.com/owner/repo.git`
- SSH: `git@gitlab.com:owner/repo.git` 或 `git@gitlab.example.com:owner/repo.git`
- 提取 `owner/repo`（或完整路径用于自托管）用于后续创建 GitLab Release

**既不是 GitHub 也不是 GitLab**：
- 通知用户此技能仅支持 GitHub 和 GitLab
- 询问是否仅执行 git tag/push（跳过 Release 创建）

检测到平台后，继续执行步骤 1

### 步骤 1: 分析提交并更新 CHANGELOG

自动分析最近的 Git 提交并更新 CHANGELOG.md：

1. **获取自上次发布以来的提交**：

```bash
# 获取最新标签
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# 获取自上次标签之后的提交（如果没有标签则获取所有提交）
if [ -n "$LATEST_TAG" ]; then
  git log ${LATEST_TAG}..HEAD --pretty=format:"%h|%s|%an" --reverse
else
  git log --pretty=format:"%h|%s|%an" --reverse
fi
```

2. **解析并分类提交信息**：

使用 Conventional Commits 格式进行分类：
- `feat:` → **Added**（新功能）
- `fix:` → **Fixed**（Bug 修复）
- `break:` 或 `BREAKING CHANGE:` → **Changed**（破坏性变更）
- `refactor:`, `perf:`, `chore:`, `docs:`, `test:`, `style:` → **Changed**（其他变更）

对每个提交信息：
- 提取类别（type）前缀
- 提取 scope（如果有），在描述时显示为 `scope: xxx`
- 清理消息（移除 conventional commit 前缀）
- 按类别分组

3. **更新 CHANGELOG.md**：

读取现有的 CHANGELOG.md 并更新 `[Unreleased]` 部分：

```markdown
## [Unreleased]

### Added

- scope: feature 功能描述 1
- 功能描述 2

### Changed

- scope: refactor 重构/其他变更 3
- **Breaking**: 破坏性变更 4

### Fixed

- scope: fix Bug 修复描述
```

**更新规则**：
- 如果 `[Unreleased]` 部分存在且有内容，追加新提交到相应类别
- 如果 `[Unreleased]` 部分存在但为空，填充分类后的提交
- 如果 `[Unreleased]` 部分不存在，在头部创建新部分

**实现要点**：
- 使用 Edit 工具修改 CHANGELOG.md
- 保留现有的未发布内容（如果有）
- 格式：每个要点简洁明了，使用提交消息正文
- 如果提交包含 scope，在描述前添加 `scope: xxx`
- 破坏性变更添加 `**Breaking**:` 前缀以突出显示

4. **向用户展示摘要**：

显示添加到 CHANGELOG 的内容摘要：
```
分析了 X 个提交（自 v{version} 以来）：
- 3 个 Added（新功能）
- 2 个 Changed（包括 1 个破坏性变更）
- 1 个 Fixed（Bug 修复）
```

### 步骤 2: 分析未发布变更

读取更新后的 CHANGELOG.md 并检查 `[Unreleased]` 部分，对变更进行分类：

- **MAJOR** (X.0.0): 包含破坏性变更，需要主版本升级
- **MINOR** (x.Y.0): 添加了新功能
- **PATCH** (x.y.Z): 仅有 Bug 修复

**版本决策矩阵**：
```
存在破坏性变更 → MAJOR
有新功能（无破坏性） → MINOR
仅 Bug 修复 → PATCH
```

### 步骤 3: 确定新版本号

1. 从 git 标签获取当前版本：`git describe --tags --abbrev=0`
2. 解析版本号（MAJOR.MINOR.PATCH）
3. 根据分类的变更应用版本升级
4. 向用户展示决策并请求确认

**示例展示**：
```
当前版本：1.2.3
未发布变更：
- Breaking: 破坏性变更说明
- Added: 新功能描述
- Fixed: Bug 修复说明

推荐版本：2.0.0（检测到破坏性变更）
确认？(yes/no)
```

### 步骤 4: 更新 CHANGELOG.md

1. 将 `## [Unreleased]` 替换为 `## [X.Y.Z] - YYYY-MM-DD`
2. 在底部添加版本链接（根据平台）：

**GitHub**：
```markdown
[X.Y.Z]: https://github.com/owner/repo/compare/vA.B.C...vX.Y.Z
```

**GitLab**：
```markdown
[X.Y.Z]: https://gitlab.com/owner/repo/-/compare/vA.B.C...vX.Y.Z
```

**GitLab 自托管**：
```markdown
[X.Y.Z]: https://gitlab.example.com/owner/repo/-/compare/vA.B.C...vX.Y.Z
```

3. 提交：`git commit -m "chore: release vX.Y.Z"`

### 步骤 5: 创建并推送标签

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin main
git push origin vX.Y.Z
```

### 步骤 6: 创建 Release

#### GitHub Release

使用 `gh release create` 创建格式化的发布说明：

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --notes "## What's Changed

### Added

- scope: feature 新功能描述 1
- 新功能描述 2

### Fixed

- scope: fix Bug 修复描述

### Changed

- 其他变更描述

**Full Changelog**: https://github.com/owner/repo/compare/vA.B.C...vX.Y.Z"
```

**Release Notes 格式规范**：
- 使用英文标题 `## What's Changed`
- 使用 `### Added`、`### Fixed`、`### Changed` 分类
- 每个条目使用 `-` 开头，简洁明了
- 如果提交包含 scope，在描述前添加 `scope: xxx`
- 破坏性变更使用 `**Breaking**:` 前缀
- 链接文本使用 `**Full Changelog**:`
- 如果某个分类为空，则省略该分类
- 从 CHANGELOG.md 中提取对应版本的 `Added`、`Fixed`、`Changed` 内容

**重要提示**：如果 gh 命令因认证失败，提供用户：
1. 在 GitHub Web UI 手动创建发布的链接
2. 格式化的发布说明内容供复制粘贴

#### GitLab Release

使用 `glab release create` 创建格式化的发布说明：

```bash
glab release create vX.Y.Z \
  --name "vX.Y.Z" \
  --notes "## What's Changed

### Added

- scope: feature 新功能描述 1
- 新功能描述 2

### Fixed

- scope: fix Bug 修复描述

### Changed

- 其他变更描述

**Full Changelog**: https://gitlab.com/owner/repo/-/compare/vA.B.C...vX.Y.Z"
```

**Release Notes 格式规范**：与 GitHub Release 相同，使用统一的 `## What's Changed` 格式

**重要提示**：如果 glab 命令因认证失败，提供用户：
1. 在 GitLab Web UI 手动创建发布的链接
2. 格式化的发布说明内容供复制粘贴

**GitLab 自托管**：需要先配置 CLI 的主机地址：

```bash
glab config set host gitlab.example.com
```

## 错误处理

- **不支持的 Git 平台**：通知用户此技能仅支持 GitHub 和 GitLab，询问是否仅执行 git tag/push
- **没有未发布变更**：通知用户并询问是否继续
- **Git 工作区不干净**：中止并要求用户先提交/暂存变更
- **认证失败**：提供 Web UI 备选方案
- **推送冲突**：指示用户先 pull/rebase 再重试
- **未配置远程仓库**：中止并要求用户先配置远程仓库

## CHANGELOG 格式

期望使用 Keep a Changelog 格式：

```markdown
## [Unreleased]

### Added

- scope: feature 新功能描述

### Changed

- **Breaking**: 不兼容的变更

### Fixed

- scope: fix Bug 修复描述

## [1.0.0] - YYYY-MM-DD
...
```

## Release Notes 格式规范

创建 Release 时，**必须**使用以下统一的格式模板，以确保所有版本的一致性：

```markdown
## What's Changed

### Added

- scope: feature 新功能描述 1
- 新功能描述 2

### Fixed

- scope: fix Bug 修复描述

### Changed

- 其他变更描述（重构、性能优化等）
- **Breaking**: 破坏性变更说明（如有）

**Full Changelog**: https://github.com/owner/repo/compare/vA.B.C...vX.Y.Z
```

**格式要求**：
1. **标题固定**：使用 `## What's Changed`（英文，保持历史版本一致性）
2. **分类标准**：
   - `### Added`：新功能
   - `### Fixed`：Bug 修复
   - `### Changed`：其他变更（重构、性能优化、文档等）
3. **scope 显示**：如果提交包含 scope，在描述前添加 `scope: xxx`
4. **破坏性变更**：在 Changed 中使用 `**Breaking**:` 前缀突出显示
5. **链接文本**：使用 `**Full Changelog**:`（英文）
6. **空分类省略**：如果某个分类没有内容，则省略该分类
7. **内容来源**：从 CHANGELOG.md 中提取对应版本的内容

**示例 1 - 仅有新功能**：
```markdown
## What's Changed

### Added

- scope: feature 支持新的验证规则
- 新增配置项支持自定义行为

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.14...v1.0.15
```

**示例 2 - 多分类混合**：
```markdown
## What's Changed

### Added

- scope: feature 新增 trim 配置支持
- 新增命名参数支持

### Fixed

- 修复数据处理时的空值问题

### Changed

- CI: 优化测试运行策略

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.13...v1.0.14
```

**示例 3 - 仅 Bug 修复**：
```markdown
## What's Changed

### Fixed

- scope: fix 修复嵌套对象的验证问题

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.12...v1.0.13
```

**从 CHANGELOG 提取内容时**：
- 保留 CHANGELOG 中的原始描述
- 保持分类结构（Added/Fixed/Changed）
- 保留 scope 前缀（如果有）
- 移除日期和版本号（这些在 Release 标题中已有）
- 确保 Full Changelog 链接正确

## 平台 CLI 工具

### GitHub
- 需要安装 `gh` CLI 工具
- GitHub token 需要有 `repo` 和 `workflow` 权限
- 安装：https://cli.github.com/

### GitLab
- 需要安装 `glab` CLI 工具
- GitLab token 需要有 `api` 和 `write_repository` 权限
- 安装：https://glab.readthedocs.io/

## Conventional Commits 支持

此技能基于 Conventional Commits 规范解析提交信息：

| 类型 | 分类 | 说明 |
|------|------|------|
| `feat:` | Added | 新功能 |
| `fix:` | Fixed | Bug 修复 |
| `break:` / `BREAKING CHANGE:` | Changed | 破坏性变更 |
| `refactor:` | Changed | 代码重构 |
| `perf:` | Changed | 性能优化 |
| `chore:` | Changed | 构建/工具链更新 |
| `docs:` | Changed | 文档更新 |
| `test:` | Changed | 测试相关 |
| `style:` | Changed | 代码风格（不影响功能） |

**Scope 支持**：
- 如果提交信息包含 scope（如 `feat(api): 添加新接口`），会在描述中显示为 `scope: api 添加新接口`
- Scope 格式：`type(scope): description` 或 `type!: description`（破坏性变更）

## 使用示例

1. **发布新版本**：用户说"发布新版本"或"创建 release"
2. **版本升级**：用户提到版本号提升或打标签
3. **完成重要功能**：用户添加了重要功能或修复了多个 Bug 后
4. **定期发布**：按预定时间发布版本（如每周、每月）

## 注意事项

- 确保所有要发布的更改已提交并推送到远程
- CHANGELOG.md 应存在于仓库根目录
- GitHub: 需要安装 `gh` CLI 工具以创建 GitHub Release
- GitLab: 需要安装 `glab` CLI 工具以创建 GitLab Release
- 自托管 GitLab 实例需要额外配置 `glab` 的 host 参数
- 提交消息建议使用 Conventional Commits 格式以便自动分类
