---
name: git-issue-solver
description: 自动化处理 GitHub/GitLab Issue 的完整工作流：获取 issue → 分支管理（含 worktree）→ 代码实现 → 提交 → 创建 PR/MR。使用场景：用户要求处理 issue、解决 bug、实现功能、贴了 issue 链接
---

# Git Issue Solver（GitHub / GitLab）

**默认行为**：用户直接调用本技能且无任何提示时，自动进入拉取 issue 列表流程。

## 执行流程

### 步骤 0: 验证 Git 平台

```bash
git remote get-url origin
```

解析 URL 判断平台：
- **GitHub**: `github.com` 域名
- **GitLab**: `gitlab.com` 或自托管 GitLab 域名
- **其他**: 通知用户此技能仅支持 GitHub/GitLab，询问是否继续

### 步骤 1: 获取 Issue

#### 方式 A：用户提供了 Issue 链接或编号

1. 解析链接中的 `owner/repo` 和 issue 编号（如果是编号则直接使用）
2. 与当前项目的 remote URL 比对验证归属（仅链接需要验证）
3. 不匹配时拒绝并提示：
   ```
   ❌ Issue 不属于当前项目

   链接中的项目: other-owner/other-repo
   当前项目: current-owner/current-repo

   此技能仅支持处理当前项目的 issue。
   ```

#### 方式 B：拉取 Issue 列表

使用[平台 CLI 工具](references/REFERENCE.md#平台-cli-工具)列出 issue，展示格式：

```
#123 [bug] 登录页面无法正常显示
#124 [feature] 添加用户头像上传功能
#125 [enhancement] 优化数据库查询性能
...
```

**交互选项**：输入编号选择 / `n` 下一页 / `q` 退出

### 步骤 2: 展示 Issue 详情

使用[平台 CLI 工具](references/REFERENCE.md#平台-cli-工具)查看 issue 详情并展示：

```
Issue #123: 登录页面无法正常显示
状态: open | 标签: bug, priority-high | 作者: username | 指派: assignee
```

**注意事项**：
- 如果 issue 已指派给其他人，提醒用户：`⚠️ 此 issue 已指派给 @other-user，继续处理可能导致重复工作。是否继续？(y/n)`
- 如果用户是通过列表选择的（方式 B），展示详情后需确认：`确认处理此 issue？(y/n)`
- 如果用户主动提供了链接或编号（方式 A），意图已明确，展示详情后直接进入下一步

### 步骤 3: 工作区检查与分支准备

#### 检查当前分支

```bash
git rev-parse --abbrev-ref HEAD
```

如果当前不在主分支（main/master/develop），提示用户确认 base branch：

```
⚠️ 当前在分支 feature/other-work，不是主分支。

新分支的起点：
1. 从主分支 main 创建（推荐）
2. 从当前分支 feature/other-work 创建

请选择 (1/2):
```

#### 检查工作区状态

```bash
git status --porcelain
```

- **工作区干净** → 直接创建分支，无需额外交互
- **有未提交更改** → 建议使用 worktree：
  ```
  ⚠️ 工作区有未提交的更改（5 个文件）

  建议使用 worktree 创建独立工作环境，避免影响当前工作。
  使用 worktree？(y/n，默认 y)
  ```

### 步骤 4: 创建分支 / Worktree

#### 分支命名规范

| Issue 类型 | 格式 | 示例 |
|-----------|------|------|
| Bug | `fix/<#>-<desc>` | `fix/123-login-blank` |
| 功能 | `feat/<#>-<desc>` | `feat/124-avatar` |
| 重构 | `refactor/<#>-<desc>` | `refactor/125-query` |
| 文档 | `docs/<#>-<desc>` | `docs/126-readme` |
| 其他 | `issue/<#>-<desc>` | `issue/127-misc` |

> 此命名规范与 `git-commit` 技能配合：git-commit 会自动从分支名提取 issue 编号（如 `fix/123-login-blank` → `#123`），并关联到提交消息中。

#### 方式 A：创建 Worktree

1. 检查现有 worktree 位置确定存放目录（遵循现有模式，默认 `.worktree/`）
2. 创建 worktree：
   ```bash
   mkdir -p .worktree
   git worktree add .worktree/fix-123-login-blank -b fix/123-login-blank
   ```
3. 提示用户切换工作目录：
   ```
   ✅ Worktree 已创建
   - 分支: fix/123-login-blank
   - 目录: /absolute/path/.worktree/fix-123-login-blank

   请在新目录中继续工作。后续命令将使用绝对路径操作此目录。
   ```
4. 后续所有文件操作使用 worktree 的绝对路径

#### 方式 B：直接创建分支

```bash
git checkout -b fix/123-login-blank
```

### 步骤 5: 分析并实现 Issue

1. 理解需求：分析 issue 描述、标签、评论
2. 定位代码：搜索相关文件
3. 制定方案：复杂问题先询问用户
4. 编写代码：实现功能或修复
5. 验证实现：运行测试或手动验证

提交时调用 `git-commit` 技能，保持提交原子性，一个提交解决一个问题。

### 步骤 6: 完成与后续

```
✅ Issue #123 处理完成

📋 处理摘要：
- 分支: fix/123-login-blank
- 提交: 3 个 | 修改文件: 5 个

📝 已完成：修复登录页面渲染问题、添加单元测试
```

**后续操作**（询问用户）：

```
下一步：
1. 创建 PR/MR（推荐）
2. 仅推送分支到远程
3. 暂不操作

请选择 (1/2/3):
```

选择创建 PR/MR 时，使用[平台 CLI 工具](references/REFERENCE.md#平台-cli-工具)创建，body 中包含 `Closes #<number>` 关联 issue。

如果使用了 worktree，额外提示清理命令：
```
💡 Worktree 清理: git worktree remove .worktree/fix-123-login-blank
```

---

## 错误处理

| 场景 | 处理 |
|-----|------|
| CLI 未安装 | 提示安装 `gh`/`glab` |
| 认证失败 | 提示重新登录 |
| 分支已存在 | 建议换名或切换现有分支 |
| Worktree 冲突 | 提示删除冲突项 |

---

## 使用示例

- `帮我处理 #123`
- `https://github.com/owner/repo/issues/123`
- `看看有哪些待处理的 issue`
- `处理一个高优先级的 bug`
