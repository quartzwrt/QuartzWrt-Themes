# QuartzWrt-Themes（`themes` feed）

QuartzWrt 的**第三方主题软件源**：收录经许可核对的上游 LuCI 主题，整仓镜像、
版本锁定、随 QuartzWrt 的签名 apk 源发布。**主题不预装**，用户按需安装。

## 收录（2026-11-22 首轮）

| 包 | 上游 | 许可 |
| :--- | :--- | :--- |
| `luci-theme-vantage` / `luci-app-vantage` / `luci-app-vantage-aps` | [anothaDev/luci-theme-vantage](https://github.com/anothaDev/luci-theme-vantage)（v1.1.1） | GPL-3.0-or-later |
| `luci-theme-7dollar` | [itsmaiGe/luci-theme-7dollar](https://github.com/itsmaiGe/luci-theme-7dollar)（v1.0.18） | Apache-2.0 |
| `luci-theme-aurora` / `luci-app-aurora-config` | [eamonxg/luci-theme-aurora](https://github.com/eamonxg/luci-theme-aurora)（1.4.3） | Apache-2.0 |

锁定 commit、排除项与避撞规则见 [`docs/FORKS.md`](docs/FORKS.md)。

## 使用

- **设备安装**（固件已接入 QuartzWrt 软件源）：
  ```sh
  apk update
  apk add luci-theme-vantage      # 或 luci-theme-7dollar / luci-theme-aurora (+ luci-app-aurora-config)
  ```
  安装后在 LuCI → 系统 → 语言和界面选择主题。
- **dashboard 互斥**：安装 `luci-app-vantage` 后，`luci-app-dashboard` 的
  `zzz-quartz-dashboard-gate.json` 会按当前主题切换落地页——quartz 主题 → QuartzWrt
  dashboard；vantage 主题 → `admin/dashboard-vantage`（vantage/overview）。切换主题时
  由 `quartz-dashboard-gate` 触发器刷新菜单缓存。7Dollar 自带 Home/Devices/Apps 入口。
- **构建接入**：`QuartzWrt-Builder/config/feeds.conf.extra` 追加
  `src-git themes https://github.com/quartzwrt/QuartzWrt-Themes.git^<commit>`；
  `CONFIG_FEED_themes=m`（未发布/发布前在 distfeeds 中注释输出）。

## 结构

```text
themes/<名>/          # 上游整仓镜像（包目录 + LICENSE/NOTICE）
scripts/sync-mirrors.sh
docs/FORKS.md         # 台账：上游/锁定/许可/排除/节奏
.github/workflows/sync-upstreams.yml  # 每周同步并开 PR（审查后合并）
```

## 纪律

- 只收录上游**未被基座 luci feed 提供**的主题（argon/bootstrap/footstrap/material/
  openwpt/openwpt-2020 不收录）。
- 纯镜像、不改包；适配（如 dashboard 门控）一律落在 `quartz` feed 的自有包里。
- 上游更新走定时 PR，逐项 review 许可与依赖后合并；发布轮再 bump Builder 的 feed 锁定。
