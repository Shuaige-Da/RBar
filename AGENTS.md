# Repository Instructions

## Project Overview

- `RBar.slnx` is the repository entry solution.
- `DynamicIslandBar/` contains the WPF application; its published assembly name is `RBar`.
- `DynamicIslandBar.Tests/` contains the xUnit test suite.
- Generated output, local configuration, logs, credentials, and signing keys must never be committed.

## Required Validation

Before considering a code change complete, run the checks appropriate to its scope. For application changes, the default is:

```powershell
dotnet build .\RBar.slnx -c Release
dotnet test .\RBar.slnx -c Release --no-build
git diff --check
```

Preserve taskbar restoration and backward-compatible configuration behavior. UI changes should be checked at more than one Windows display scale when possible.

## Git Sync Workflow Preference

When the user asks to "pull" or "sync" code from another remote branch into the current work:

1. Keep the current local branch checked out unless the user explicitly asks to switch branches.
2. Fetch the target remote branch first.
3. Apply the target branch's code into the current working tree while staying on the current local branch.
4. Commit the synced code on the current local branch.
5. Do not push unless the user explicitly asks to push.

### Current Preferred Pattern

For this repository, if the user asks to pull `origin/master` while working on `win-ui1.0-优化版`, interpret that as:

- stay on `win-ui1.0-优化版`
- fetch `origin/master`
- bring `origin/master` code into the current working tree
- create a new local commit on `win-ui1.0-优化版`
- keep the remote tracking branch as `origin/win-ui1.0-优化版` unless the user explicitly requests a push
