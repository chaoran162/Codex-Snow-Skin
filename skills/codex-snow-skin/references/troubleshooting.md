# Troubleshooting

## Installer says Codex Dream Skin is active

Use the original project's Restore launcher first. Snow Skin refuses to run two injectors against the same Codex window.

## Installer cannot find official Codex

Install and open the Microsoft Store Codex app once. Development builds, unpacked copies, web installs, and renamed packages are intentionally unsupported.

## Node.js 22+ was not found

Open official Codex once so it can provision its local runtime. Otherwise install Node.js 22+ and make `node.exe` available on `PATH`.

## Port is occupied

The normal launcher searches up to 100 ports when the default is busy. A manually specified busy port fails instead of connecting to an unknown process.

## Codex opens but the theme is absent

Run `scripts/verify-snow-skin.ps1`. Check `%LOCALAPPDATA%\CodexSnowSkin\setup.log`, `verify.log`, `injector.log`, and `injector-error.log`. If verification mentions missing shell markers, a Codex update likely changed the renderer structure; restore the official skin and update Snow Skin before retrying.

## Codex closes during first setup

One restart is expected and requires confirmation. A first launch after a Store update can take up to two minutes while package identity and the renderer settle. If Codex does not reopen, use the normal Codex Start menu entry. Setup rollback attempts to remove the new injector and reopen Codex without debugging flags.

## Custom image does not appear

Use `Codex Snow Skin - Customize` and choose a valid PNG, JPEG, or BMP from 320x180 through 40 megapixels and under 50 MB. Choose `Apply now`, or start Codex from `Codex Snow Skin` later. Details from a failed graphical customization are written to `%LOCALAPPDATA%\CodexSnowSkin\customize.log`.

## Restore cannot identify a process

Do not force-kill by process name. Preserve `%LOCALAPPDATA%\CodexSnowSkin\state.json`, close Codex normally, and rerun Restore. Stale state is archived when the saved PID no longer matches its expected executable and command line.

## Config write fails

Close other programs editing `%USERPROFILE%\.codex\config.toml`. Snow Skin refuses unsupported multiline or duplicate target keys and aborts if the file changes during the transaction.
