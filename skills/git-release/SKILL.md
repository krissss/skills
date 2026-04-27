---
name: git-release
description: 自动化 GitHub/GitLab/Gitea 发布流程。使用场景：发布新版本、创建版本标签、更新 CHANGELOG。自动分析 Git 提交、更新 CHANGELOG.md、确定语义化版本号、创建 Git 标签、推送到远程并创建 Release
---

# Git 自动发布（GitHub / GitLab / Gitea）

自动化 GitHub/GitLab/Gitea Release 发布流程，遵循语义化版本（Semantic Versioning）规范。自动分析 Git 提交记录并更新 CHANGELOG.md，然后确定合适的版本号并完成发布。

## 发布流程

### 步骤 0: 确认 Git 平台

**如果对话中已通过任意 git 技能确定过平台信息（平台 + owner/repo），直接复用，跳过本步骤。**

首次检测时执行：

```bash
git remote get-url origin
```

解析 URL 判断平台：
- **GitHub**: `github.com` 域名 → 提取 `owner/repo`
- **GitLab**: `gitlab.com` 或自托管域名 → 提取 `owner/repo`
- **其他域名**: 尝试调用 `<域名>/api/v1/version` 检测是否为 Gitea 实例
  - 成功识别 → 作为 **Gitea** 处理，提取 `owner/repo`
  - 检测失败 → 提示用户手动选择平台（GitHub/GitLab/Gitea/其他），或询问是否仅执行 git tag/push

检测完成后记住平台信息，供后续 git 技能复用。

### 步骤 1: 准备发布数据

收集并计算所有发布所需信息，**不执行任何写操作**。

#### 1.1 获取自上次发布以来的提交

先获取最新 tag：
```bash
git describe --tags --abbrev=0 2>/dev/null
```

有 tag 时查看后续提交：
```bash
git log v1.2.3..HEAD --pretty=format:"%h %s" --reverse
```

无 tag 时查看全部提交：
```bash
git log --pretty=format:"%h %s" --reverse
```

对包含 `!` 后缀的提交或需要检查 body 的提交，单独获取完整信息：
```bash
git log <hash> -1 --pretty=format:"%B"
```

#### 1.2 解析并分类提交信息

| 类型 | CHANGELOG 分类 | 说明 |
|------|---------------|------|
| `feat` / `feature` | Added | 新功能 |
| `fix` / `bugfix` | Fixed | Bug 修复 |
| `!` 后缀 / `BREAKING CHANGE` footer | Changed | 破坏性变更 |

以下类型默认不进入 CHANGELOG：`refactor`、`perf`、`chore`、`docs`、`test`、`style`。如果某个提交确实值得记录（如重大性能优化），可酌情归入 Changed。

**破坏性变更检测**：
- **类型后加 `!`**：`feat!: 移除旧 API` 或 `feat(api)!: 移除旧端点`
- **Footer 中声明**：`BREAKING CHANGE: v1 端点不再可用`

**Scope 处理**：提交格式 `type(scope): description` → CHANGELOG/Release Notes 中显示为 `scope: description`

#### 1.3 确定版本号

- 存在破坏性变更 → **MAJOR** (X.0.0)
- 有 `feat` 类提交（无破坏性） → **MINOR** (x.Y.0)
- 仅有 `fix` 类提交 → **PATCH** (x.y.Z)

确定版本号后先与用户确认：

```
当前版本：1.2.3
分析了 X 个提交（自 v1.2.3 以来）：
- 3 个 Added（新功能）
- 1 个 Changed（包括 1 个破坏性变更）
- 1 个 Fixed（Bug 修复）

推荐版本：v2.0.0（检测到破坏性变更）
确认版本号？(y/输入其他版本号)
```

用户确认版本号后才继续生成 CHANGELOG 和 Release Notes。

#### 1.4 生成 CHANGELOG 内容

基于分类结果，准备 CHANGELOG.md 的变更内容（在内存中生成，不写入文件）。

**条目格式**：
- scope 显示为 `scope:` 格式：`- api: 添加新接口`
- 无 scope 直接写描述：`- 新功能描述`
- 破坏性变更添加前缀：`- **Breaking**: 变更说明`

#### 1.5 生成 Release Notes

```markdown
## What's Changed

### Added

- scope: 新功能描述

### Fixed

- scope: Bug 修复描述

### Changed

- **Breaking**: 破坏性变更说明

**Full Changelog**: https://github.com/owner/repo/compare/vA.B.C...vX.Y.Z
```

**格式要求**：
1. 标题固定使用 `## What's Changed`（英文，保持历史版本一致性）
2. 分类：`### Added`（新功能）、`### Fixed`（Bug 修复）、`### Changed`（其他变更）
3. 空分类省略，不要输出空的分类标题
4. GitLab 链接使用 `/-/compare/` 路径格式，Gitea 链接使用 `/compare/` 路径格式（同 GitHub）

### 步骤 2: 预览确认

将所有发布数据一次性展示给用户：

```
📦 发布预览

版本：v2.0.0（当前 v1.2.3）
提交：分析了 X 个提交（自 v1.2.3 以来）

--- CHANGELOG 变更 ---
（展示将写入 CHANGELOG.md 的完整 diff）

--- Release Notes ---
（展示完整的 Release Notes）

确认发布？可修改版本号、CHANGELOG 内容或 Release Notes。(y/n)
```

用户可要求修改任何部分，修改后重新预览，再次确认。**用户明确确认后才进入步骤 3。**

### 步骤 3: 执行发布

用户确认后，按顺序执行以下操作：

#### 3.1 更新 CHANGELOG.md

1. 将 `## [Unreleased]` 替换为 `## [X.Y.Z] - YYYY-MM-DD`
2. 在 `## [X.Y.Z]` 上方插入新的空 `## [Unreleased]`（保持 Keep a Changelog 规范）
3. 在文件底部添加版本比较链接：

**GitHub**：
```markdown
[X.Y.Z]: https://github.com/owner/repo/compare/vA.B.C...vX.Y.Z
[Unreleased]: https://github.com/owner/repo/compare/vX.Y.Z...HEAD
```

**GitLab**：
```markdown
[X.Y.Z]: https://gitlab.com/owner/repo/-/compare/vA.B.C...vX.Y.Z
[Unreleased]: https://gitlab.com/owner/repo/-/compare/vX.Y.Z...HEAD
```

**Gitea**：
```markdown
[X.Y.Z]: https://gitea.example.com/owner/repo/compare/vA.B.C...vX.Y.Z
[Unreleased]: https://gitea.example.com/owner/repo/compare/vX.Y.Z...HEAD
```

#### 3.2 提交 CHANGELOG

```bash
git add CHANGELOG.md
git commit -m "chore: release vX.Y.Z"
```

#### 3.3 创建并推送标签

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
```

获取当前分支名后推送：
```bash
git branch --show-current
# 用输出的分支名执行：
git push origin <branch>
git push origin vX.Y.Z
```

#### 3.4 创建 Release

**GitHub**：

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --notes "$(cat <<'EOF'
...（格式化的 Release Notes）
EOF
)"
```

**GitLab**：

```bash
glab release create vX.Y.Z \
  --name "vX.Y.Z" \
  --notes "$(cat <<'EOF'
...（格式化的 Release Notes）
EOF
)"
```

自托管 GitLab 需先配置：`glab config set host gitlab.example.com`

**Gitea**：

```bash
tea releases create \
  --tag vX.Y.Z \
  --title "vX.Y.Z" \
  --note "$(cat <<'EOF'
...（格式化的 Release Notes）
EOF
)"
```

自托管 Gitea 需先配置：`tea login add --url=https://gitea.example.com --token=...`

**认证失败时**：提供 Web UI 手动创建发布的链接，以及格式化的发布说明供复制粘贴。

## 错误处理

| 场景 | 处理 |
|-----|------|
| 不支持的 Git 平台 | 通知用户，询问是否仅执行 git tag/push |
| 没有未发布变更 | 通知用户并询问是否继续 |
| Git 工作区不干净 | 中止并要求用户先提交/暂存变更 |
| 认证失败（gh/glab/tea） | 提供 Web UI 备选方案和格式化内容 |
| 推送冲突 | 指示用户先 pull/rebase 再重试 |
| 未配置远程仓库 | 中止并要求用户先配置 |

## 注意事项

- 确保所有要发布的更改已提交
- CHANGELOG.md 应存在于仓库根目录
- 提交消息建议使用 Conventional Commits 格式以便自动分类
