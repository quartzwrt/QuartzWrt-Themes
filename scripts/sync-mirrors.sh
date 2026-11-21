#!/usr/bin/env bash
# QuartzWrt-Themes 上游主题镜像同步（TDD §3.1 / §4.7；模型与 QuartzWrt-ThirdParty 相同）
#
# 机制：把各上游主题仓的指定 ref 以「整仓镜像」方式同步到 themes/<名>/（排除 .git
#       与开发/CI 噪声目录），feed 由本仓提供、锁定沿用本仓 commit。纯镜像、无适配：
#       主题的 dashboard 互斥由 QuartzWrt-Packages 的 luci-app-dashboard 门控承接
#       （zzz-quartz-dashboard-gate.json），不改主题包本身。
#
# 用法：scripts/sync-mirrors.sh [名称 ...]      （缺省同步全部）
# 同步后：① review `git diff`；② 更新 docs/FORKS.md（上游 commit / 上次同步日期）；
#         ③ 提交（发布轮再 bump Builder 的 themes 锁定）。
#
# 映射表：名称|仓库 URL|ref（分支或 tag）|源子路径（. = 整仓）|镜像目标|排除（空格分隔）
#   - 均为上游直取（无适配需求，不建 fork）；排除项只去除开发/CI/预编译产物，
#     保留包目录（Makefile/htdocs/root/ucode/po）与 LICENSE/NOTICE。
#   - 新增主题：加一行映射 + docs/FORKS.md 登记 + 许可核对（基座 luci feed 已有的
#     argon/bootstrap/footstrap/material/openwpt/openwpt-2020 不得收录——先列者胜遮蔽，
#     且第三方主题源不重复基座内容）。

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

ENTRIES=(
  "vantage|https://github.com/anothaDev/luci-theme-vantage.git|main|.|themes/vantage|.github dev prototypes security-tests tests keys .release-manifests"
  "7dollar|https://github.com/itsmaiGe/luci-theme-7dollar.git|main|.|themes/7dollar|.github dist docs scripts"
  "aurora|https://github.com/eamonxg/luci-theme-aurora.git|master|.|themes/luci-theme-aurora|.github .dev .vscode .claude docs"
  "aurora-config|https://github.com/eamonxg/luci-app-aurora-config.git|master|.|themes/luci-app-aurora-config|.github .dev docs"
)

want=("$@")
for e in "${ENTRIES[@]}"; do
  IFS='|' read -r name url ref subpath dest exclude <<<"$e"
  if [ "${#want[@]}" -gt 0 ]; then
    keep=0
    for w in "${want[@]}"; do [ "$w" = "$name" ] && keep=1; done
    [ "$keep" -eq 1 ] || continue
  fi
  echo "== $name：$url @ $ref"
  git clone -q --depth 1 --branch "$ref" "$url" "$TMP/$name"
  mkdir -p "$ROOT/$dest"
  ex_args=()
  for x in $exclude; do ex_args+=(--exclude="$x"); done
  rsync -a --delete --exclude=.git "${ex_args[@]}" "$TMP/$name/$subpath/" "$ROOT/$dest/"
  echo "   → $dest（$(git -C "$TMP/$name" log -1 --format='%h %s')）"
done

echo
echo "同步完成。变更概览："
git -C "$ROOT" status --short -- . | head -40
echo
echo "提醒：① review git diff；② 更新 docs/FORKS.md（上游 commit / 上次同步）；③ 提交。"
