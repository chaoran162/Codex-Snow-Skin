# Codex Snow Skin

> 本项目基于 [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 优化而来。衷心感谢原作者及贡献者公开源码、设计思路与基础实现。
>
> This project is an optimized derivative of [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin). Sincere thanks to the original author and contributors.

一个可回滚的 Windows Codex 冰雪主题 Skill。它自动识别微软商店版 Codex、创建快捷方式、校验启动身份，并在失败时尽量恢复官方启动方式。

## 最简单的使用方法

### 方法一：作为 Skill 安装（推荐）

在 Codex 中发送：

```text
请从 https://github.com/chaoran162/Codex-Snow-Skin/tree/main/skills/codex-snow-skin 安装 codex-snow-skin skill，并帮我准备安装。
```

Codex 会在桌面创建 `Install or Update Codex Snow Skin`。当前任务结束后双击它一次。安装完成后，日常从 `Codex Snow Skin` 进入；换背景使用 `Codex Snow Skin - Customize`；Store 更新后可以重新点一次安装器。

### 方法二：下载后直接安装

1. 在 GitHub 的 `Code` 菜单下载 ZIP 并解压。
2. 双击 `Install Codex Snow Skin.cmd`。
3. 安装完成后使用 `Codex Snow Skin` 快捷方式。

第一次安装需要关闭并重新打开 Codex，脚本会先确认，未确认不会结束 Codex。

## 换成自己的图片

最简单的方法是双击桌面或开始菜单中的 `Codex Snow Skin - Customize`：

1. 点击 `Choose image...` 选择 PNG、JPEG 或 BMP 图片。
2. 选择是否立即应用。若 Codex 需要重启，会在关闭前明确提醒。
3. 点击 `Use default` 可以恢复仓库自带的冰雪图。

图片会在本机居中裁剪成 1920x1080，只写入 `%LOCALAPPDATA%\CodexSnowSkin\custom-background.png`，不会复制进仓库或上传到 GitHub。支持 320x180 至 4000 万像素、最大 50 MB 的有效图片，并自动处理常见 JPEG 旋转方向。

也可以双击仓库根目录的 `Customize Codex Snow Skin.cmd`，或向 Codex 发送：

```text
用 codex-snow-skin 把 "D:\Pictures\ski.png" 设置为我的本地背景。
```

高级用法：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\skills\codex-snow-skin\scripts\set-snow-image.ps1" -ImagePath "D:\Pictures\ski.png"
```

重新应用或启动 `Codex Snow Skin` 后生效。恢复默认图：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\skills\codex-snow-skin\scripts\set-snow-image.ps1" -Reset
```

自定义图片在恢复官方外观后仍保留在本机，方便下次安装继续使用；在自定义器中点击 `Use default` 才会删除该本地副本。请只使用你有权使用的图片。本仓库不附带名人肖像、赛事徽标、奥运标识或用户私人图片。

## 恢复官方外观

双击桌面的 `Codex Snow Skin - Restore`，或双击仓库根目录的 `Restore Official Codex Skin.cmd`。恢复会关闭主题注入器、关闭本地调试端口，并恢复安装前的 Codex 基础配色。

## 支持范围

- Windows 10/11 x64。
- 微软商店安装、包名为 `OpenAI.Codex`、非开发签名的官方 Codex。
- PowerShell 5.1 或更高版本。
- Codex 已准备好的内置 Node.js 22+，或者系统 `PATH` 中的 Node.js 22+。

目前不支持 macOS、Linux、网页版 Codex、解包版、开发签名包或第三方重打包版本。若当前 Codex 页面结构在更新后变化，验证会报错并停止安装，不会尝试修改官方应用文件。

## 它会改什么

- 备份后更新 `%USERPROFILE%\.codex\config.toml` 中的基础颜色字段。
- 在 `%LOCALAPPDATA%\CodexSnowSkin` 保存状态、日志、备份及本地自定义背景。
- 通过仅监听回环地址的 Chromium DevTools Protocol 注入 CSS 和界面装饰。
- 创建安装、启动、自定义和恢复快捷方式。

它不会修改 `WindowsApps`、`ChatGPT.exe`、`app.asar`、Codex 登录信息、API Token、环境变量或你的项目文件。

## 安全提醒

主题会在运行期间打开一个仅限本机回环地址的调试端口（默认 `9335`）。CDP 不验证同一 Windows 用户下的其他本地进程，因此主题开启时只运行可信软件；不用主题时执行恢复即可关闭端口。状态中记录包身份、可执行文件路径、浏览器 ID、Node 路径和进程启动时间，停止进程前会再次比对，避免按名称误关其他程序。

## 排错

先查看 `%LOCALAPPDATA%\CodexSnowSkin\setup.log`、`injector-error.log` 和 `verify.log`。完整排错表见 [troubleshooting.md](skills/codex-snow-skin/references/troubleshooting.md)。

运行测试：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\skills\codex-snow-skin\tests\run-tests.ps1"
```

## 许可证与声明

代码与仓库内无人物冰雪背景采用 [MIT License](LICENSE)。本项目为非官方社区项目，与 OpenAI 无附属、认可或赞助关系。原项目归属、第三方素材边界和运行时说明见 [NOTICE.md](NOTICE.md)。
