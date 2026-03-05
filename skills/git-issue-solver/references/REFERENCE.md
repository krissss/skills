# 参考资料

## 平台 CLI 工具

### GitHub

```bash
gh issue list --state open --limit 20     # 列出 issue
gh issue view <number>                     # 查看详情
gh issue comment <number> --body "..."     # 添加评论
gh pr create --title "..." --body "Closes #<number>"  # 创建 PR
```

### GitLab

```bash
glab issue list --state opened --per-page 20  # 列出 issue
glab issue view <number>                       # 查看详情
glab issue note <number> --message "..."       # 添加评论
glab mr create --title "..." --description "Closes #<number>"  # 创建 MR
```

### Gitea

```bash
tea issues list --state open --limit 20        # 列出 issue
tea issues view <number>                       # 查看详情
tea issues comment <number> --body "..."       # 添加评论
tea pr create --title "..." --body "Closes #<number>"  # 创建 PR
```

---

## Worktree 管理

```bash
git worktree list                          # 查看所有
git worktree remove .worktree/<name>       # 删除指定
git worktree prune                         # 清理无效
```

**建议**：将 `.worktree/` 添加到 `.gitignore`
