# RBar

RBar 是一款由个人开发者 rainwave 制作、面向 Windows 11 的桌面胶囊工具，将运行中应用、媒体信息、同步歌词和常用系统状态集中在一个可自定义的透明胶囊中，并提供配套控制中心。

> 当前目标平台为 Windows 11 x64。项目采用 MIT License，欢迎通过 Issue 和 Pull Request 参与改进。

## 系统要求

- Windows 11 x64
- 推荐使用自包含安装包，无需另外安装 .NET Desktop Runtime
- Wi-Fi、音量、运行中应用等功能可能受 Windows 权限、系统服务和硬件能力限制

## 安装

1. 下载 `RBar-Setup-v*-win-x64-self-contained.exe`。
2. 运行安装程序并选择简体中文或 English。
3. 根据需要选择桌面快捷方式和开机自启。
4. 安装完成后启动 RBar。

当前 `v1.0.0` 个人开发者构建尚未进行代码签名，Windows 可能显示 `Unknown publisher`。请只从本仓库 Releases 页面下载，并核对发布说明中的 SHA-256；不要安装来源不明或哈希不一致的文件。

## 主要功能

- 顶部、底部、左右停靠及浮动胶囊布局
- 运行中应用展示、搜索、激活与最小化
- 键盘方向键导航和 Enter 激活
- 媒体信息、播放控制和同步歌词
- Wi-Fi、音量、电池及扩展系统功能
- 蓝色透明与白色透明主题
- 控制中心与胶囊背景独立设置
- 功能区域显隐、透明度和自动隐藏设置
- 配置导入、导出和诊断信息复制

## 升级

直接运行更高版本安装程序即可覆盖升级。请不要修改安装器的应用标识或手动删除安装目录，否则可能影响升级识别。

升级会保留用户配置。稳妥起见，可在控制中心的“配置管理”中先导出配置文件。

## 卸载与用户数据

可从 Windows“设置 > 应用 > 已安装的应用”卸载 RBar。

卸载时：

- 删除程序文件、快捷方式和开机启动项
- 恢复 Windows 原任务栏
- 删除诊断日志和权限决定
- 保留个性化配置，便于重新安装后恢复设置

用户数据目录：

```text
%LocalAppData%\RBar
```

其中 `capsule-config.json` 和 `capsule-config.json.bak` 会保留。若检测到旧版 `%LocalAppData%\DynamicIslandBar` 数据，RBar 首次启动会复制现有配置、权限和日志，不删除旧文件。若希望彻底清理，可在卸载后手动删除两个目录。用户自己选择的背景图片只会记录原文件路径，卸载不会删除原图片。

## 网络与隐私

- 歌词功能会根据当前媒体信息访问网易云音乐歌词接口和 LRCLIB。
- 诊断日志保存在本机，默认不会自动上传。
- 反馈上传渠道尚未配置。反馈页中输入的文字和选择的图片当前不会发送给开发者或服务器。
- 诊断报告设计为不包含歌词、歌曲名、应用列表、用户文件路径和反馈附件；提交前仍建议用户自行检查内容。

## 已知限制

- 部分 Wi-Fi 操作需要 Windows 位置权限或系统服务支持。
- 某些受保护、管理员权限或特殊窗口类型的应用可能无法被普通权限程序控制。
- 歌词是否可用以及时间轴准确度取决于第三方歌词数据。
- 多显示器不同 DPI、任务栏替代软件和桌面增强工具可能影响胶囊定位。
- 反馈提交功能暂未启用。

## 诊断与反馈

遇到问题时，请在控制中心的“版本信息 > 诊断中心”复制诊断内容，并在项目 Issue 页面说明：

- Windows 版本和显示缩放比例
- 胶囊停靠位置
- 可稳定复现的操作步骤
- 实际结果和预期结果

问题反馈：[GitHub Issues](https://github.com/Shuaige-Da/RBar/issues)

## 构建

克隆仓库后，在 Windows PowerShell 中运行：

```powershell
git clone https://github.com/Shuaige-Da/RBar.git
cd RBar
dotnet restore .\RBar.slnx
dotnet build .\RBar.slnx -c Release --no-restore
dotnet test .\RBar.slnx -c Release --no-build
```

生成面向普通用户的自包含发布包：

```powershell
.\scripts\Build-Release.ps1 -Version 1.0.0 -SelfContained
```

发布输出位于 `artifacts\release`。正式发布前必须核对自动化测试、安装程序、数字签名、SHA-256 和干净 Windows 11 冒烟测试结果。

正式 Release 提供三种下载：

- `Self-contained Setup`：自包含安装程序，无需预先安装 .NET。
- `Framework-dependent Setup`：不捆绑 .NET，需要 .NET 8 Desktop Runtime x64。
- `Portable ZIP`：自包含便携版，解压后直接运行 `RBar.exe`。

当前个人开发者发布包尚未进行代码签名，文件名和 Release 说明会明确标记 `UNSIGNED`。Windows 可能显示 `Unknown publisher`，请从本仓库 Release 页面下载并核对 SHA-256。

## 项目结构

```text
DynamicIslandBar/        WPF 应用（程序集名称为 RBar）
DynamicIslandBar.Tests/  xUnit 自动化测试
release/installer/       Inno Setup 安装脚本与中文语言资源
scripts/                 发布构建脚本
docs/                    架构与发布说明
.github/                 CI、依赖更新和协作模板
```

架构说明见 [docs/architecture.md](docs/architecture.md)，开发规范见 [CONTRIBUTING.md](CONTRIBUTING.md)，版本变更见 [CHANGELOG.md](CHANGELOG.md)。

## 参与贡献

提交问题前请先搜索已有 Issue。代码变更应通过完整测试，UI 变更请附带截图、显示缩放和停靠位置。安全漏洞请遵循 [SECURITY.md](SECURITY.md)，不要在公开 Issue 中披露。

## 许可证

RBar 使用 [MIT License](LICENSE) 开源。

```text
Copyright (c) 2026 rainwave
```

第三方组件和翻译资源仍受其各自许可证约束，详情见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)。
