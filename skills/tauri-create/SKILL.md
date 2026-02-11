---
name: tauri-create
description: Tauri 项目创建向导。使用场景：创建新的 Tauri 应用
---

# Tauri 项目创建

## 功能概述

交互式创建 Tauri 跨平台桌面应用项目。引导用户完成模板选择、UI 框架安装、Git 初始化、端口配置等步骤。

## 交互方式

**所有询问尽量使用 `AskUserQuestion` 工具进行交互式问答**。

## 快速创建流程

### 步骤 1：获取项目信息

**检查当前目录**：执行 `ls -A` 检查当前目录是否为空。

**决定创建位置**：
- 当前目录为空：使用 `AskUserQuestion` 询问用户是**在当前目录创建**还是**创建子目录**
- 当前目录非空：告知用户将创建子目录

**选择模板**：使用 `AskUserQuestion` 询问用户模板选择，默认推荐 `vue-ts`。

| 模板参数 | 技术栈 |
|---------|--------|
| `vue-ts` | Vue + TypeScript（推荐） |
| `vue` | Vue |
| `react-ts` | React + TypeScript |
| `react` | React |
| `svelte-ts` | Svelte + TypeScript |
| `svelte` | Svelte |
| `vanilla-ts` | Vanilla + TypeScript |
| `vanilla` | Vanilla JS |

**执行创建**：

在当前目录创建（空目录）：
```bash
pnpm create tauri-app . --template <模板> --yes
pnpm install
```

创建子目录：
```bash
pnpm create tauri-app <项目名> --template <模板> --yes
cd <项目名>
pnpm install
```

### 步骤 2：Git 初始化（建议）

**检查 Git 状态**：执行 `git rev-parse --git-dir > /dev/null 2>&1` 检查当前目录是否已是 git 仓库。

- 如已是 git 仓库：告知用户，跳过初始化，后续步骤会直接提交
- 如非 git 仓库：使用 `AskUserQuestion` 询问用户是否需要 Git 版本管理

告知后续每步操作都会提交一次 git，记录创建过程。

如需要初始化，立即执行：

```bash
git init && git add . && git commit -m "init"
```

### 步骤 3：安装 UI 框架

使用 `AskUserQuestion` 询问用户：**是否需要使用 UI 框架？**

如需要，根据已选择的模板推荐合适的框架，并立即执行安装命令。

**如已选择 Git**，安装完成后提交：

```bash
git add .
git commit -m "feat: add UI framework"
```

### 步骤 4：端口配置

使用 `AskUserQuestion` 询问用户：**是否使用默认的 1420 端口？**

如不是，让用户指定新端口号，立即编辑 `vite.config.ts` 和 `tauri.conf.json` 修改端口。

**如已选择 Git**，修改完成后提交：

```bash
git add .
git commit -m "config: change port to <新端口>"
```

### 步骤 5：安装 window-state 插件

使用 `AskUserQuestion` 询问用户：**是否需要窗口状态记忆功能（桌面端）？**

说明好处：自动记住窗口位置和大小，下次打开保持原样。

如需要，立即执行：

```bash
pnpm tauri add window-state
```

**如已选择 Git**，安装完成后提交：

```bash
git add .
git commit -m "feat: add window-state plugin"
```

### 步骤 6：创建 AGENTS.md

提示 AI 根据项目当前情况生成一份 AGENTS.md 文件，内容需要额外包含：提醒使用 `tauri-best-practices` 技能。

**如已选择 Git**，创建完成后提交：

```bash
git add AGENTS.md
git commit -m "docs: add AGENTS.md"
```

### 步骤 7：告知开发命令

创建完成后告知用户：

```bash
pnpm dev          # 纯网页开发
pnpm tauri dev    # 开发模式
pnpm tauri build  # 构建应用
```

## 使用示例

### 场景 1：全新项目创建（空目录）

**用户输入**："帮我创建一个 Tauri 应用"

**交互流程**：
1. 检查当前目录为空
2. 询问用户：在当前目录创建还是创建子目录？
3. 询问模板选择（推荐 vue-ts）
4. 执行创建命令
5. 询问是否初始化 Git
6. 询问是否需要 UI 框架（根据模板推荐）
7. 询问端口配置
8. 询问是否安装 window-state 插件
9. 创建 AGENTS.md
10. 告知开发命令

### 场景 2：指定模板创建

**用户输入**："用 React 创建一个 Tauri 项目"

**处理方式**：
1. 直接使用 react-ts 模板（推荐 TypeScript）
2. 如用户明确说不使用 TS，则使用 react 模板
3. 其余流程同场景 1

### 场景 3：快速创建（跳过交互）

**用户输入**："快速创建一个基础的 Tauri 项目，不需要额外配置"

**处理方式**：
1. 使用默认模板（vue-ts）
2. 创建子目录或使用当前目录（如为空）
3. 跳过 Git、UI 框架、端口、插件等询问
4. 仅完成基础创建和依赖安装

### 场景 4：在现有项目中创建

**用户输入**："在当前目录创建 Tauri 项目"（当前目录非空）

**处理方式**：
1. 告知用户将创建子目录
2. 询问项目名称
3. 在子目录中完成创建

## 注意事项

- **环境要求**：确保已安装 Node.js 18+ 和 pnpm
- **Rust 工具链**：如需编写自定义 Rust 代码，需额外安装 Rust
- **此技能范围**：仅负责项目创建和初始配置，不涉及后续开发
- **插件安装限制**：`pnpm tauri add` 一次只能添加一个插件，需多次执行
- **Git 提交策略**：每完成一个配置步骤立即提交，记录创建过程
- **端口冲突**：如 1420 端口被占用，建议用户修改端口
- **最佳实践**：创建完成后提醒用户参考 `tauri-best-practices` 技能

## 参考资源

- [Tauri 2.x 官方文档](https://v2.tauri.app/zh-cn/)
- [Tauri 插件列表](https://v2.tauri.app/zh-cn/plugin/)
