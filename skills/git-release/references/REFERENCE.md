# Git Release 详细参考

## CHANGELOG 格式

期望使用 [Keep a Changelog](https://keepachangelog.com/) 格式：

```markdown
# Changelog

## [Unreleased]

## [1.1.0] - 2025-01-15

### Added

- api: 新增分页支持
- 新增配置项

### Changed

- **Breaking**: 移除旧的认证方式

### Fixed

- auth: 修复登录超时问题

## [1.0.0] - 2025-01-01
...

[Unreleased]: https://github.com/owner/repo/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/owner/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/owner/repo/releases/tag/v1.0.0
```

### 条目格式

- scope 显示为 `scope:` 格式：`- api: 添加新接口`
- 无 scope 直接写描述：`- 新功能描述`
- 破坏性变更添加前缀：`- **Breaking**: 变更说明`

### 版本比较链接

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

## Release Notes 格式

```markdown
## What's Changed

### Added

- scope: 新功能描述 1
- 新功能描述 2

### Fixed

- scope: Bug 修复描述

### Changed

- 其他变更描述
- **Breaking**: 破坏性变更说明

**Full Changelog**: https://github.com/owner/repo/compare/vA.B.C...vX.Y.Z
```

**格式要求**：
1. 标题固定使用 `## What's Changed`（英文，保持历史版本一致性）
2. 分类：`### Added`（新功能）、`### Fixed`（Bug 修复）、`### Changed`（其他变更）
3. scope 显示为 `scope:` 格式
4. 破坏性变更在 Changed 中使用 `**Breaking**:` 前缀
5. 链接文本使用 `**Full Changelog**:`
6. 空分类省略，不要输出空的分类标题
7. GitLab 链接使用 `/-/compare/` 路径格式，Gitea 链接使用 `/compare/` 路径格式（同 GitHub）

### 示例

**仅有新功能**：
```markdown
## What's Changed

### Added

- auth: 支持 OAuth2 登录
- 新增配置项支持自定义行为

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.14...v1.0.15
```

**多分类混合**：
```markdown
## What's Changed

### Added

- api: 新增分页支持

### Fixed

- 修复数据处理时的空值问题

### Changed

- **Breaking**: 移除 v1 API 端点

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.13...v1.0.14
```

## Conventional Commits 支持

此技能基于 Conventional Commits 规范解析提交信息，与 git-commit 技能的类型定义保持一致。

### 进入 CHANGELOG 的类型

| 类型 | 分类 | 说明 |
|------|------|------|
| `feat` / `feature` | Added | 新功能 |
| `fix` / `bugfix` | Fixed | Bug 修复 |
| `!` 后缀 / `BREAKING CHANGE` footer | Changed | 破坏性变更 |

### 默认不进入 CHANGELOG 的类型

以下类型通常不是面向用户的变更，默认跳过。如果某个提交确实值得记录（如重大性能优化），可酌情归入 Changed：

`refactor`、`perf`、`chore`、`docs`、`test`、`style`

### 破坏性变更检测

按 Conventional Commits 标准识别，不使用 `break:` 前缀：

- **类型后加 `!`**：`feat!: 移除旧 API` 或 `feat(api)!: 移除旧端点`
- **Footer 中声明**：`BREAKING CHANGE: v1 端点不再可用`

检测 footer 时需获取提交完整信息：`git log <hash> -1 --pretty=format:"%B"`

### Scope 处理

- 提交格式：`type(scope): description`
- CHANGELOG/Release Notes 中显示为：`scope: description`

## 平台 CLI 工具

### GitHub

- 需要安装 [`gh`](https://cli.github.com/) CLI 工具
- Token 需要有 `repo` 和 `workflow` 权限

```bash
gh release create vX.Y.Z --title "vX.Y.Z" --notes "..."
```

### GitLab

- 需要安装 [`glab`](https://glab.readthedocs.io/) CLI 工具
- Token 需要有 `api` 和 `write_repository` 权限
- 自托管实例需配置：`glab config set host gitlab.example.com`

```bash
glab release create vX.Y.Z --name "vX.Y.Z" --notes "..."
```

### Gitea

- 需要安装 [`tea`](https://gitea.com/gitea/tea) CLI 工具（`brew install tea` / `go install code.gitea.io/tea@latest`）
- 自托管实例需配置：`tea login add --url=https://gitea.example.com --token=...`

```bash
tea releases create --tag vX.Y.Z --title "vX.Y.Z" --note "..."
```
