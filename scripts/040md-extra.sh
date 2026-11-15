#!/bin/bash
# ================================================================
# 040MD 专用插件拉取（上游 diy-part1.sh 不带这两个）
#   1) laipeng668/luci-app-gecoosac —— Build/Prepare 用 `cp ../LICENSE`（相对包目录
#      的上一级），因此必须把【整个仓库】克隆进 package/custom，否则 .prepared 阶段
#      因找不到 LICENSE 直接 Error 1。
#   2) anothaDev/luci-theme-vantage —— 主题包在 subdir luci-theme-vantage/，
#      必须拷子目录出来（否则 buildroot 扫不到 Makefile）。
# ================================================================
set -euo pipefail

PKG_DIR="package/custom"
mkdir -p "$PKG_DIR"

clone() {  # clone <url> <dir> [branch]
  local url="$1" dir="$2" br="$3"
  if [ -d "$dir" ]; then echo "已存在，跳过: $dir"; return 0; fi
  echo "--- git clone $url -> $dir ---"
  if [ -n "$br" ]; then
    git clone --depth 1 -b "$br" "$url" "$dir" 2>&1 | tail -3
  else
    git clone --depth 1 "$url" "$dir" 2>&1 | tail -3
  fi
  if [ -d "$dir" ]; then
    echo "✅ 克隆成功: $dir"
    return 0
  fi
  echo "::error::克隆失败: $url"
  return 1
}

echo "===== 040MD 专用插件 ====="
clone https://github.com/laipeng668/luci-app-gecoosac "$PKG_DIR/gecoosac-repo" main
[ -f "$PKG_DIR/gecoosac-repo/LICENSE" ] && echo "✅ gecoosac 整仓就位（../LICENSE 可解析）"

VANTAGE_TMP="$(mktemp -d)/vantage"
clone https://github.com/anothaDev/luci-theme-vantage "$VANTAGE_TMP" main
if [ -d "$VANTAGE_TMP/luci-theme-vantage" ]; then
  rm -rf "$PKG_DIR/luci-theme-vantage"
  cp -a "$VANTAGE_TMP/luci-theme-vantage" "$PKG_DIR/luci-theme-vantage"
  echo "✅ 已拷贝: luci-theme-vantage"
else
  echo "::error::luci-theme-vantage 子目录不存在"
fi
rm -rf "$VANTAGE_TMP"
echo "===== 040MD 专用插件 完成 ====="
