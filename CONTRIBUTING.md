# 参与贡献

感谢你愿意帮助改进 RBar。提交代码前，请先阅读本说明，以便变更易于审查、验证和维护。

## 开发环境

- Windows 11 x64
- .NET 10 SDK（应用目标框架为 .NET 8，使用现代 SDK 以支持根目录的 `.slnx` 解决方案）
- Visual Studio 2022（可选，推荐安装“.NET 桌面开发”工作负载）
- Inno Setup 6（仅生成安装程序时需要）

## 本地构建

```powershell
dotnet restore .\RBar.slnx
dotnet build .\RBar.slnx -c Release --no-restore
dotnet test .\RBar.slnx -c Release --no-build
```

生成完整发布包：

```powershell
.\scripts\Build-Release.ps1 -Version 1.0.0 -SelfContained
```

## 提交变更

1. 从最新目标分支创建功能分支。
2. 一个提交只处理一类问题，避免混入无关格式化或生成文件。
3. 新功能和缺陷修复应补充对应测试；UI 变更应说明手工验证的窗口尺寸与 DPI。
4. 不要提交 `bin`、`obj`、`artifacts`、日志、用户配置、签名证书或其他本机文件。
5. 提交 Pull Request 前运行完整测试，并确认 `git diff --check` 没有空白错误。

## 代码约定

- 保持可空引用类型启用，不使用空的 `catch` 隐藏可恢复范围之外的错误。
- UI 线程中避免同步等待、磁盘扫描和网络访问。
- 持久化配置变更必须提供默认值、范围校验和旧版本迁移策略。
- Windows 原生调用需要明确资源释放路径，并在权限不足或 API 不可用时安全降级。
- 公共行为优先通过小型策略类和单元测试表达，避免继续扩大窗口代码后的职责。

## 问题与安全漏洞

普通缺陷和功能建议请使用仓库的 Issue 模板。安全问题不要公开披露，请按照 [SECURITY.md](SECURITY.md) 提交私密报告。
