# RBar 架构概览

RBar 是一个面向 Windows 11 的 WPF 桌面应用。应用保持单进程运行，并把界面、系统集成和可测试策略分成以下几类。

## 主要入口

- `Program.cs`：单实例、旧配置迁移和应用启动。
- `MainWindow.xaml/.cs`：胶囊窗口、交互编排和 Windows 功能集成。
- `CapsuleControlCenterWindow.xaml/.cs`：主题、设置、诊断和反馈界面。
- `CapsuleConfigService.cs`：配置默认值、校验、迁移和持久化。

## 领域与策略

- `CapsulePresentation`、`CapsuleAutoHidePolicy`：功能区域显隐、透明度和自动隐藏。
- `CapsuleLayoutManager`、`CenterCardLayoutPolicy`：不同停靠方向下的布局计算。
- `RunningAppsService`、`LocalAppSearchService`：应用枚举、搜索和图标加载。
- `MediaService`、`LyricsService`：系统媒体会话与第三方歌词数据。
- `AudioService`、`WifiService`、`SystemFeatureToggleService`：Windows 系统能力。
- `TaskbarManager`、`TaskbarRestoreWatchdog`：任务栏隐藏与异常恢复。

## 数据目录

运行时数据位于 `%LocalAppData%\RBar`：

- `capsule-config.json`：用户配置。
- `capsule-config.json.bak`：最近一次可恢复备份。
- `permissions.json`：权限决定。
- `Logs`：本机诊断日志。

首次启动会从旧版 `%LocalAppData%\DynamicIslandBar` 复制已知数据；已有 RBar 文件始终优先。

## 测试策略

`DynamicIslandBar.Tests` 覆盖配置、布局、展示状态、应用操作、歌词匹配、任务栏恢复和关键 XAML/代码契约。涉及真实 Windows 外部状态的功能需要在干净 Windows 11 环境进行手工冒烟测试。

## 设计约束

- 不在滚动卡片上创建大量独立实时 Shader 或模糊层。
- 不在 UI 线程执行网络、全盘搜索或长时间系统查询。
- Windows API 不可用或权限不足时必须保持程序可退出，并恢复系统任务栏。
- 配置字段只能以向后兼容方式演进。
