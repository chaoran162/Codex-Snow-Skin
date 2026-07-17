# QA inventory

## Release gates

- All PowerShell files parse in Windows PowerShell 5.1.
- `tests/run-tests.ps1`, injector self-tests, payload construction, and JavaScript syntax checks pass.
- Skill metadata validation passes.
- Secret and private-material scan finds no credentials, personal paths, private images, celebrity likenesses, or protected event marks.
- Cold start identifies the registered Store package, keeps CDP identity stable, injects the current theme version, and writes verified state.
- Restore removes live DOM/CSS, closes CDP, stops only the recorded injector, restores config colors, and reopens official Codex normally.

## Visual checks

- Home and task views remain readable at 1280x820 and a narrow window.
- Native sidebar, project selector, composer, cards, menus, scrollbars, and task navigation remain interactive.
- No decoration intercepts pointer input or covers essential controls.
- Custom images crop to 16:9 without changing layout dimensions.
- The graphical customizer selects or resets a local-only image and never writes user art inside the skill directory.

## Failure checks

- Occupied explicit port fails clearly; automatic selection does not attach to an unverified listener.
- Reused PID, mismatched Node path, old package identity, changed Browser ID, fake `app://` target, or remote WebSocket URL is rejected.
- Verification failure stops the new injector and reopens Codex without debug flags.
- Concurrent operations fail on the named mutex without changing config or state.
- Invalid, empty, undersized, oversized, or unsupported custom images fail before replacing the previous local background.
- A Codex Store update either passes selectors and verification or exits with a useful log; it does not patch installed files.
- Existing Codex Dream Skin state blocks setup to prevent injector conflicts.
