---
name: codex-snow-skin
description: Install, update, customize, verify, troubleshoot, or safely remove the reversible Codex Snow Skin on Windows. Use when a user asks for an ice/ski/snow Codex theme, wants a personal local background, needs Snow Skin launchers, reports that the skin did not react or Codex closed unexpectedly, or wants to restore the official Codex appearance.
---

# Codex Snow Skin

Manage the Windows Snow Skin without modifying the official Codex package or exposing user images.

## Route The Request

- For first install or update, run `scripts/create-launchers.ps1`. Tell the user to finish the current task and then double-click `Install or Update Codex Snow Skin` on the desktop.
- Never run `setup-snow-skin.ps1` from an active Codex task. It intentionally closes Codex once and would interrupt the task.
- For a personal background, run `scripts/set-snow-image.ps1 -ImagePath <absolute-path>`. The script writes only to `%LOCALAPPDATA%\CodexSnowSkin`; tell the user to relaunch using `Codex Snow Skin`.
- For default artwork, run `scripts/set-snow-image.ps1 -Reset`.
- For a health check while Snow Skin is active, run `scripts/verify-snow-skin.ps1`. Inspect `%LOCALAPPDATA%\CodexSnowSkin\verify.log` and `injector-error.log` if it fails.
- For removal, direct the user to desktop `Codex Snow Skin - Restore`. Do not close the active Codex task without explicit user confirmation.

## Install Workflow

1. Confirm the host is Windows and resolve the official non-development Store package with `scripts/common-windows.ps1` helpers.
2. Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-root>\scripts\create-launchers.ps1"
```

3. Report the created desktop path and explain that the launcher asks before closing Codex.
4. After the user returns, run `scripts/verify-snow-skin.ps1` and report the exact failure log when verification does not pass.

## Guardrails

- Support only Windows 10/11 x64 and the registered `OpenAI.Codex` Microsoft Store package.
- Do not edit `WindowsApps`, `ChatGPT.exe`, `app.asar`, API keys, login state, environment variables, or user projects.
- Do not copy user backgrounds into this skill or a Git repository. Do not upload them.
- Do not bundle celebrity likenesses, protected event marks, or third-party art without explicit rights.
- Do not stop a process by name alone. Use the Store package identity and exact executable path checks in `common-windows.ps1`.
- Treat the loopback CDP port as sensitive to other processes running as the same Windows user. Recommend Restore when the theme is not needed.
- If `%LOCALAPPDATA%\CodexDreamSkin\state.json` exists, require the original Dream Skin to be restored first.

Read `references/troubleshooting.md` for failure handling and `references/runtime-notes.md` before changing process, state, CDP, or config behavior.
