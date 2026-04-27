#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "用法:"
  echo "  安装: $0 [--dry-run] <来源目录> <目标目录>"
  echo "  卸载: $0 --uninstall <来源目录> <目标目录>"
  echo ""
  echo "  来源目录: 包含 SKILL.md 的单 skill 目录，或包含多个 skill 子目录的父目录"
  echo "  目标目录: 软链安装位置 (默认: ~/.agents)"
}

DRY_RUN=false
UNINSTALL=false
ARGS=()

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --uninstall) UNINSTALL=true ;;
    --help|-h) usage; exit 0 ;;
    -*) echo "未知选项: $arg" >&2; usage; exit 1 ;;
    *) ARGS+=("$arg") ;;
  esac
done

# 解析参数
if [ "${#ARGS[@]}" -ge 1 ]; then
  SOURCE_DIR="$(cd "${ARGS[0]}" && pwd)"
else
  # 默认使用脚本所在仓库的 skills/ 目录
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  SOURCE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

TARGET_DIR="${ARGS[1]:-$HOME/.agents/skills}"

# 校验来源目录
if [ ! -d "$SOURCE_DIR" ]; then
  echo "错误: 来源目录不存在: $SOURCE_DIR" >&2
  exit 1
fi

# 收集要安装的 skill 目录
collect_skills() {
  local src="$1"
  if [ -f "$src/SKILL.md" ]; then
    # 单 skill 目录
    echo "$src"
  else
    # 多 skill 父目录，扫描子目录
    for sub in "$src"/*/; do
      [ -d "$sub" ] || continue
      if [ -f "${sub}SKILL.md" ]; then
        echo "$sub"
      else
        echo "ERROR:${sub%/}"
      fi
    done
  fi
}

# 卸载模式
if [ "$UNINSTALL" = true ]; then
  if [ ! -d "$TARGET_DIR" ]; then
    echo "目标目录 $TARGET_DIR 不存在，无需卸载"
    exit 0
  fi

  # 获取来源目录下的所有 skill 名
  skill_names=()
  while IFS= read -r skill_dir; do
    if [[ "$skill_dir" == ERROR:* ]]; then
      continue
    fi
    skill_names+=("$(basename "$skill_dir")")
  done < <(collect_skills "$SOURCE_DIR")

  if [ "${#skill_names[@]}" -eq 0 ]; then
    echo "来源目录中未找到有效 skill: $SOURCE_DIR"
    exit 1
  fi

  for name in "${skill_names[@]}"; do
    link_path="$TARGET_DIR/$name"
    if [ -L "$link_path" ]; then
      echo "删除软链: $name"
      [ "$DRY_RUN" = true ] || rm "$link_path"
    fi
  done
  echo "卸载完成"
  exit 0
fi

# 安装模式
mkdir -p "$TARGET_DIR"

installed=0
errors=()

while IFS= read -r skill_dir; do
  if [[ "$skill_dir" == ERROR:* ]]; then
    invalid="${skill_dir#ERROR:}"
    errors+=("$invalid")
    continue
  fi

  skill_name="$(basename "$skill_dir")"
  link_path="$TARGET_DIR/$skill_name"

  if [ -L "$link_path" ]; then
    existing="$(readlink "$link_path")"
    if [ "$existing" = "$skill_dir" ]; then
      echo "已存在: $skill_name"
      continue
    else
      echo "覆盖: $skill_name (原指向 $existing)"
      [ "$DRY_RUN" = true ] || rm "$link_path"
    fi
  elif [ -e "$link_path" ]; then
    echo "跳过: $skill_name (存在同名文件/目录，不会覆盖)"
    continue
  fi

  echo "创建软链: $skill_name -> $skill_dir"
  [ "$DRY_RUN" = true ] || ln -s "$skill_dir" "$link_path"
  installed=$((installed + 1))
done < <(collect_skills "$SOURCE_DIR")

echo ""
echo "安装完成: $TARGET_DIR (新建 $installed 个)"

if [ "${#errors[@]}" -gt 0 ]; then
  echo ""
  echo "❌ 跳过 ${#errors[@]} 个无效目录（未找到 SKILL.md）:" >&2
  for err in "${errors[@]}"; do
    echo "  - $(basename "$err")" >&2
  done
  exit 1
fi
