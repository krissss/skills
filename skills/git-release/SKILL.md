---
name: git-release
description: 自动化 GitHub/GitLab/Gitea 发布流程。使用场景：发布新版本、创建版本标签、更新 CHANGELOG。自动分析 Git 提交、更新 CHANGELOG.md、确定语义化版本号、创建 Git 标签、推送到远程并创建 Release
---

# Git 自动发布（GitHub / GitLab / Gitea）

自动化 GitHub/GitLab/Gitea Release 发布流程，遵循语义化版本（Semantic Versioning）规范。自动分析 Git 提交记录并更新 CHANGELOG.md，然后确定合适的版本号并完成发布。

详细的 CHANGELOG 格式、Conventional Commits 规则和平台 CLI 参考见 [references/REFERENCE.md](references/REFERENCE.md)。

## 发布流程

### 步骤 0: 验证 Git 平台

```bash
git remote get-url origin
```

解析 URL 判断平台：
- **GitHub**: `github.com` 域名 → 提取 `owner/repo`
- **GitLab**: `gitlab.com` 或自托管域名 → 提取 `owner/repo`
- **其他域名**: 尝试调用 `<域名>/api/v1/version` 检测是否为 Gitea 实例
  - 成功识别 → 作为 **Gitea** 处理，提取 `owner/repo`
  - 检测失败 → 提示用户手动选择平台（GitHub/GitLab/Gitea/其他），或询问是否仅执行 git tag/push

### 步骤 1: 分析提交、更新 CHANGELOG 并确定版本

1. **获取自上次发布以来的提交**：

```bash
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$LATEST_TAG" ]; then
  git log ${LATEST_TAG}..HEAD --pretty=format:"%h %s" --reverse
else
  git log --pretty=format:"%h %s" --reverse
fi
```

对包含 `!` 后缀的提交或需要检查 body 的提交，单独获取完整信息：

```bash
git log <hash> -1 --pretty=format:"%B"
```

2. **解析并分类提交信息**：

按 [REFERENCE.md 中的 Conventional Commits 规则](references/REFERENCE.md#conventional-commits-支持) 分类。分类结果同时用于 CHANGELOG 更新和版本号决策。

**版本升级判定**：
- 存在破坏性变更 → **MAJOR** (X.0.0)
- 有 `feat` 类提交（无破坏性） → **MINOR** (x.Y.0)
- 仅有 `fix` 类提交 → **PATCH** (x.y.Z)

3. **更新 CHANGELOG.md**：

读取现有的 CHANGELOG.md，更新 `[Unreleased]` 部分。格式见 [REFERENCE.md#changelog-格式](references/REFERENCE.md#changelog-格式)。

**更新规则**：
- `[Unreleased]` 存在且有内容 → 追加新提交到相应类别
- `[Unreleased]` 存在但为空 → 填充分类后的提交
- `[Unreleased]` 不存在 → 在头部创建新部分
- scope 显示为 `scope:` 格式，破坏性变更添加 `**Breaking**:` 前缀

4. **向用户展示摘要并确认版本号**：

```
当前版本：1.2.3
分析了 X 个提交（自 v1.2.3 以来）：
- 3 个 Added（新功能）
- 1 个 Changed（包括 1 个破坏性变更）
- 1 个 Fixed（Bug 修复）

推荐版本：2.0.0（检测到破坏性变更）
确认？(yes/no)
```

### 步骤 2: 更新 CHANGELOG.md 版本信息

1. 将 `## [Unreleased]` 替换为 `## [X.Y.Z] - YYYY-MM-DD`
2. 在 `## [X.Y.Z]` 上方插入新的空 `## [Unreleased]`（保持 Keep a Changelog 规范）
3. 在文件底部添加版本比较链接（GitHub: `/compare/`，GitLab: `/-/compare/`，Gitea: `/compare/`）
4. 提交变更：

```bash
git add CHANGELOG.md
git commit -m "chore: release vX.Y.Z"
```

### 步骤 3: 创建并推送标签

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin $(git branch --show-current)
git push origin vX.Y.Z
```

### 步骤 4: 创建 Release

从 CHANGELOG.md 中提取对应版本的 Added/Fixed/Changed 内容，按 [REFERENCE.md 中的 Release Notes 格式](references/REFERENCE.md#release-notes-格式) 生成发布说明。

#### GitHub

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --notes "$(cat <<'EOF'
...（格式化的 Release Notes）
EOF
)"
```

#### GitLab

```bash
glab release create vX.Y.Z \
  --name "vX.Y.Z" \
  --notes "$(cat <<'EOF'
...（格式化的 Release Notes）
EOF
)"
```

自托管 GitLab 需先配置：`glab config set host gitlab.example.com`

#### Gitea

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
