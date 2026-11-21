# 第三方主题台账（TDD §3.1 · themes feed）

本文件登记 `QuartzWrt-Themes`（feed 标识 **`themes`**）收录的上游主题、锁定状态、
许可与镜像规则。**纯镜像、无适配**：主题包保持上游字节内容；dashboard 落地页互斥由
`QuartzWrt-Packages` 的 `luci-app-dashboard` 门控（`zzz-quartz-dashboard-gate.json` +
`/etc/init.d/quartz-dashboard-gate`）承接，不修改主题/应用包。

## 收录清单（2026-11-22 首轮）

| 主题/包 | 上游 | 镜像路径 | 锁定（2026-11-22） | 许可 | 说明 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Vantage**（3 包）：`luci-theme-vantage` / `luci-app-vantage` / `luci-app-vantage-aps` | [anothaDev/luci-theme-vantage](https://github.com/anothaDev/luci-theme-vantage) | `themes/vantage/` | `main` @ `8729104405b85d6c43347233d1cce15c2ed8d750`（tag `v1.1.1`） | GPL-3.0-or-later | 明确面向 OpenWrt 25.12；`luci-app-vantage` 注册 `admin/dashboard`，由本仓门控处理；aps = SSH 配对 AP（可选） |
| **7Dollar**：`luci-theme-7dollar` | [itsmaiGe/luci-theme-7dollar](https://github.com/itsmaiGe/luci-theme-7dollar) | `themes/7dollar/` | `main` @ `35aa4b4660aec932b17129517ad8a28f509c991e`（tag `v1.0.18`） | Apache-2.0 | ucode LuCI（23.05+）；菜单 `admin/home`、`admin/clients`、`admin/apps` 仅主题启用时出现（无路径冲突） |
| **Aurora**：`luci-theme-aurora` / `luci-app-aurora-config` | [eamonxg/luci-theme-aurora](https://github.com/eamonxg/luci-theme-aurora)、[eamonxg/luci-app-aurora-config](https://github.com/eamonxg/luci-app-aurora-config) | `themes/luci-theme-aurora/`、`themes/luci-app-aurora-config/` | `master` @ `298dbcc74ddf820923a51285fb0826d429e5d7ca`（Makefile 1.4.3）；config `master` @ `a5299ce0144859f47683ec3bc40805bf616f534f`（tag `v1.2.5`） | Apache-2.0 | Vite/Tailwind；无 menu.d；config 为可选配置页；共享 `luci-theme-devkit` 仅为开发包，不收录 |

**避撞**：基座 luci feed 已含 argon/bootstrap/footstrap/material/openwpt/openwpt-2020
六个主题（`feeds/luci/themes/`），同名一律不收录（先列者胜遮蔽 + 第三方主题源不重复基座）。

## 镜像与排除

- 同步脚本：`scripts/sync-mirrors.sh`（整仓 `rsync --delete`，排除 `.git` 与开发/CI 目录）。
- **目录名 = 包名（重要）**：luci.mk 对未显式 `PKG_NAME` 的包按**目录名**派生包名
  （aurora/aurora-config 即此类），因此镜像目录必须保持上游 `luci-theme-*` /
  `luci-app-*` 命名；vantage/7dollar 的 Makefile 显式 `PKG_NAME`，目录名不变。
- 排除项：vantage `.github dev prototypes security-tests tests keys .release-manifests`；
  7dollar `.github dist docs scripts`；aurora `.github .dev .vscode .claude docs`；
  aurora-config `.github .dev docs`。包目录与 `LICENSE`/`NOTICE` 保留。
- **节奏**（kwrt 式聚合、审查闸门）：`.github/workflows/sync-upstreams.yml` 每周一
  03:00 UTC 自动同步并开 PR；人工 review diff（许可/依赖/包结构）后合并。
- 发布：Builder `config/feeds.conf.extra` 锁定本仓 commit；主题包为 `arch=all`，
  由构建期 feed-only 编译编入软件源（不预装），用户 `apk add` 安装。
