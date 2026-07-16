# 开发工具

`ScreenshotTool` 是一个仅供本地 UI 验证使用的 Windows 窗口截图工具，不参与 RBar 的正式构建或发布。

```powershell
dotnet run --project .\tools\ScreenshotTool.csproj -- output.png RBar
```

第一个参数为输出 PNG 路径，第二个参数为目标进程名。输出图片属于本地测试产物，不应提交到仓库。
