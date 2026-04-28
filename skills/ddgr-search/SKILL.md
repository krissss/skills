---
name: ddgr-search
description: 使用 ddgr 在终端搜索 DuckDuckGo，返回结构化结果。支持站点限定、时间过滤、区域搜索。使用场景：用户要求搜索信息、查找文档、搜索特定网站内容
---

# DuckDuckGo 搜索（ddgr）

使用 [ddgr](https://github.com/jarun/ddgr) 在终端搜索 DuckDuckGo，以 JSON 格式获取结构化结果。

## 前置条件

需要安装 ddgr：

```bash
# macOS
brew install ddgr
# Debian/Ubuntu
sudo apt install ddgr
# 从源码
pip3 install ddgr
```

## 执行流程

### 步骤 0: 检查环境

**如果对话中已确认 ddgr 可用，跳过本步骤。**

```bash
which ddgr
```

未安装则提示用户安装。

### 步骤 1: 解析搜索意图

从用户输入中提取搜索参数：

| 参数 | 对应用户意图 | 选项 |
|------|-------------|------|
| 关键词 | 搜索内容 | 必需，直接使用用户的搜索词 |
| 站点限定 | "在 GitHub 上搜索"、"搜 stackoverflow" | `-w <域名>` |
| 时间过滤 | "最近的"、"最近一周的" | `-t d`(天) / `-t w`(周) / `-t m`(月) / `-t y`(年) |
| 结果数量 | "多搜几条"、"只要前 3 条" | `-n <数量>`（默认 10，最大 25） |
| 区域 | "用德语搜"、"日本地区" | `-r <地区代码>` 如 `de-de`、`jp-jp` |

### 步骤 2: 执行搜索

使用 JSON 输出模式执行搜索，获取结构化结果：

```bash
ddgr --json --np -n <数量> [-w <域名>] [-t <时间>] [-r <地区>] <关键词>
```

- `--json`：JSON 格式输出
- `--np`：搜索后不进入交互模式

### 步骤 3: 展示结果

将 JSON 结果格式化展示给用户：

```
🔍 搜索结果（共 N 条）：<关键词>

1. 标题
   🔗 URL
   📄 摘要内容...

2. 标题
   🔗 URL
   📄 摘要内容...
```

**展示规则**：
- 每条结果包含标题、URL 和摘要
- 摘要过长时截断，保留核心信息
- 如果结果为空，告知用户未找到相关内容，建议调整关键词

## 使用示例

- `搜索 DuckDuckGo：Python async 教程`
- `在 GitHub 上搜索 ddgr`
- `搜一下最近一个月的 Claude Code 相关新闻`
- `搜索 stackoverflow：Python list comprehension`
- `用德语搜索 Bundesliga`

## 注意事项

- DuckDuckGo Bang（`!w` 等）在终端中需转义为 `\!w`
- 时间过滤 (`-t`) 偶尔会返回 HTTP 202 错误，属 DuckDuckGo 限制，可去掉该参数重试
- 搜索结果数量受 DuckDuckGo 限制，最多 25 条/页
