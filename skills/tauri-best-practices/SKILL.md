---
name: tauri-best-practices
description: Tauri 框架最佳实践指南。使用场景：Tauri 应用开发、代码审查、架构设计
---

# Tauri 最佳实践

## 功能概述

Tauri 跨平台桌面应用开发最佳实践。

> 💡 创建新项目请使用 [tauri-create](../tauri-create/) 技能。

## 核心原则

### 1. 优先使用 JS 插件，避免编写 Rust 代码

**为什么**：
- 减少编译时间
- 降低 Rust 学习成本
- Tauri 2.x 插件生态已完善

**常用官方插件**：

| 插件              | 功能 | 安装命令 |
|------------------|------|----------|
| `shell`          | 打开 URL、执行命令 | `pnpm tauri add shell` |
| `fs`             | 文件系统访问 | `pnpm tauri add fs` |
| `dialog`         | 文件对话框 | `pnpm tauri add dialog` |
| `notification`   | 系统通知 | `pnpm tauri add notification` |
| `clipboard`      | 剪贴板操作 | `pnpm tauri add clipboard-manager` |
| `http`           | HTTP 请求 | `pnpm tauri add http` |
| `store`          | 数据持久化 | `pnpm tauri add store` |
| `window-state`   | 窗口状态记忆 | `pnpm tauri add window-state` |

> 📌 完整插件列表：https://v2.tauri.app/zh-cn/plugin/

**注意事项**：

1. **插件安装限制**：`pnpm tauri add` 一次只能添加一个插件

```bash
pnpm tauri add clipboard-manager
pnpm tauri add window-state
```

2. **插件导入方式**：分全部导入和解构导入

```typescript
// 导入全部方法
import * as Clipboard from '@tauri-apps/plugin-clipboard-manager'
// 然后使用
await Clipboard.writeText(text)

// 解构导入
import { writeText, readText } from '@tauri-apps/plugin-clipboard-manager'
```

### 2. 前端封装 API 层，支持浏览器开发

**架构设计**：

```
src/
├── api/
│   └── clipboard.ts           # 封装好的剪贴板 API
├── lib/
│   └── platform.ts            # 环境检测
└── main.ts
```

**实现示例**：

```typescript
// src/lib/platform.ts
export const isTauri = () => '__TAURI__' in window

// src/api/clipboard.ts
import * as Clipboard from '@tauri-apps/plugin-clipboard-manager'
import { isTauri } from '@/lib/platform'

export async function writeText(text: string): Promise<void> {
  if (isTauri()) {
    await Clipboard.writeText(text)
  } else {
    await navigator.clipboard.writeText(text)
  }
}

export async function readText(): Promise<string> {
  if (isTauri()) {
    return await Clipboard.readText()
  } else {
    return await navigator.clipboard.readText()
  }
}

// 使用
import { writeText, readText } from '@/api/clipboard'
await writeText('Hello')
```

**Web 不支持的处理方式**：

```typescript
// 方式 1：返回默认值/Mock 数据
export async function getAppVersion(): Promise<string> {
  if (isTauri()) {
    return await app.getVersion()
  }
  return '0.0.0-browser'  // 开发时使用模拟值
}

// 方式 2：抛出明确错误
export async function readFile(path: string): Promise<string> {
  if (isTauri()) {
    return await fs.readTextFile(path)
  }
  throw new Error('File API 仅在桌面端可用')
}

// 方式 3：提供降级方案
export async function saveData(key: string, value: string): Promise<void> {
  if (isTauri()) {
    await fs.writeTextFile(`data/${key}.txt`, value)
  } else {
    localStorage.setItem(key, value)  // 浏览器降级到 localStorage
  }
}
```

**优势**：
- 单文件维护，只需关注一个实现
- 浏览器开发，热更新快
- 统一接口，易于使用

---

## 使用示例

### 场景 1：审查现有项目

**用户输入**："帮我审查一下这个 Tauri 项目的代码"

**审查要点**：
1. 检查是否优先使用了官方插件而非自定义 Rust 代码
2. 检查是否有前端 API 层封装（如 `src/api/` 目录）
3. 检查是否支持浏览器开发模式
4. 检查插件导入方式是否合理
5. 提出改进建议

### 场景 2：实现新功能

**用户输入**："我需要实现剪贴板功能"

**推荐方案**：
1. 使用官方 `@tauri-apps/plugin-clipboard-manager` 插件
2. 在 `src/api/clipboard.ts` 中封装 API
3. 添加环境检测，支持浏览器降级
4. 业务代码直接调用封装后的 API

### 场景 3：性能优化建议

**用户输入**："编译时间太长了，有什么优化建议？"

**优化方向**：
1. 减少自定义 Rust 代码，优先使用 JS 插件
2. 检查 `Cargo.toml` 中不必要的依赖
3. 使用开发模式的增量编译
4. 考虑使用前端封装层在浏览器中开发

### 场景 4：架构设计咨询

**用户输入**："我要设计一个 Tauri 应用的架构"

**架构建议**：
1. 前端优先：大部分功能用前端技术栈实现
2. API 层封装：在 `src/api/` 中统一封装 Tauri API
3. 环境抽象：通过 `isTauri()` 检测实现双环境支持
4. 插件优先：优先使用官方插件，避免编写 Rust 代码

## 常见问题

### 问题：什么时候需要编写 Rust 代码？

**判断标准**：
- 现有插件无法满足需求 → 考虑自定义 Rust 代码
- 需要操作系统级别的特殊功能 → 可能需要 Rust
- 性能敏感的操作（如大量数据处理） → 可以考虑 Rust

**优先级**：官方插件 > 社区插件 > 自定义 Rust 代码

### 问题：如何处理浏览器不支持的功能？

**三种处理方式**（详见上文"前端封装 API 层"章节）：
1. 返回默认值/Mock 数据（适合开发阶段）
2. 抛出明确错误（适合必须功能）
3. 提供降级方案（如 localStorage 替代文件系统）

### 问题：插件一次安装失败怎么办？

**注意事项**：
- `pnpm tauri add` 一次只能添加一个插件
- 需要多次执行安装命令
- 安装后需要在 `src-tauri/capabilities/default.json` 中配置权限

### 问题：如何测试 Tauri 应用？

**推荐流程**：
1. 使用 `pnpm dev` 进行纯前端开发（快速热更新）
2. 核心功能完成后使用 `pnpm tauri dev` 测试桌面端集成
3. 构建前使用 `pnpm tauri build` 在目标平台测试

## 注意事项

- **Tauri 版本**：此技能基于 Tauri 2.x，不适用于 1.x
- **插件权限**：安装插件后需要在 `src-tauri/capabilities/default.json` 中配置权限
- **双环境开发**：推荐在浏览器中开发，桌面端测试
- **性能考虑**：减少 Rust 代码可显著缩短编译时间
- **安全建议**：谨慎使用 `shell` 插件执行命令，避免命令注入风险
- **项目关联**：创建新项目建议使用 [tauri-create](../tauri-create/) 技能

## 参考资源

- [Tauri 2.x 官方文档](https://v2.tauri.app/zh-cn/)
- [Tauri 插件列表](https://v2.tauri.app/zh-cn/plugin/)
- [Tauri GitHub](https://github.com/tauri-apps/tauri)
