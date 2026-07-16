# Notices

## Upstream attribution

Codex Snow Skin is derived from and optimized on top of [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin). We sincerely thank the original author and contributors for releasing the source code, design ideas, and foundational implementation under the MIT License. The original copyright notice is retained in `LICENSE`.

## Unofficial project

Codex Snow Skin is an unofficial community customization project and is not affiliated with, endorsed by, or sponsored by OpenAI. OpenAI, Codex, and related product names and marks belong to their respective owners.

## Software and assets

The MIT License applies to the software source, documentation, and the original person-free snow artwork generated for this repository at `skills/codex-snow-skin/assets/dream-reference.png`. It does not grant rights to official application binaries, trademarks, user-supplied images, third-party artwork, event logos, character likenesses, or celebrity imagery.

Custom backgrounds are written to `%LOCALAPPDATA%\CodexSnowSkin\custom-background.png` and are not intended to be committed. Users are responsible for the rights and privacy of images they select.

## Runtime and security

The project does not redistribute Node.js. It prefers the signed Node.js runtime provisioned locally by the official Codex application, with a compatible `PATH` runtime as fallback.

The live skin uses Chromium DevTools Protocol on a loopback address. CDP has no authentication boundary against other processes running as the same Windows user. Run only trusted local software while the skin is active, and use the Restore shortcut to close the debugging session.
