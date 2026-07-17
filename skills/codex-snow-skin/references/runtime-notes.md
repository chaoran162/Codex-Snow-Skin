# Runtime notes

- Every run discovers the current registered `OpenAI.Codex` package, requires Store signature kind and non-development mode, reads the application ID from the Appx manifest, and launches its AppUserModelId through `IApplicationActivationManager`.
- The packaged executable is never started directly. Debug arguments bind CDP explicitly to `127.0.0.1` on a validated port.
- Node.js 22+ is required. Discovery prefers `%LOCALAPPDATA%\OpenAI\Codex\runtimes\cua_node\*\bin\node.exe`, then a compatible runtime on `PATH`. The real `process.execPath` and version are recorded.
- CDP is accepted only when the listener resolves to the exact Store executable, WebSocket URLs use loopback and the selected port, `/json/version` has a valid Browser ID, and page targets contain expected Codex shell markers. Startup rechecks that identity after a stability delay.
- `%LOCALAPPDATA%\CodexSnowSkin\state.json` records Browser ID, Appx full/family/application IDs, package and executable paths, port, injector and Node paths, PID, and process start time. Cleanup stops a recorded process only after its visible identity matches.
- The injector keeps the original Browser WebSocket open as an identity anchor. It exits instead of reconnecting when that browser closes or the port is reused.
- The preferred port is `9335`. An explicitly occupied port is rejected; automatic startup can search the next 100 ports.
- CDP has no authentication boundary against other processes running as the same Windows user. Restore closes the injector and Codex CDP session, then reopens Codex without debug flags.
- `config.toml` is parsed from strict UTF-8 bytes, staged in the same directory, checked for concurrent changes, and replaced with a non-null backup path through `System.IO.File.Replace`. New files use the two-argument `File.Move` overload for Windows PowerShell 5.1 compatibility.
- Install stores a byte-for-byte pre-install config backup. Restore supports selective base-color restoration or exact backup recovery and retains completed backup archives.
- Theme version comes only from `assets/theme.json`; injector and renderer receive the same value. Verification rejects a stale payload.
- Store updates are rediscovered on each launch and again while waiting for the CDP endpoint. If the Store replaces Codex during restart, the launcher follows only the newly registered package that owns the loopback port. Active state from an old package is managed only after full/family/application identity and executable path validation.
- A per-user named mutex prevents concurrent install, start, restore, and verify operations.
