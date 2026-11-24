# `gekko_stdlib`

Companion MoonBit/Wasm shim overlay package for unmodified upstream [`gleam_stdlib`](https://hex.pm/packages/gleam_stdlib), built for [`gekko`](https://github.com/spiral-nights/gekko).

Instead of forking `gleam_stdlib`, `gekko_stdlib` provides only the MoonBit FFI primitives (`moonbit/gleam_stdlib_ffi/`), in-package patches (`overlays/`), and symbol-level override configuration (`gekko.toml`) needed to compile upstream `gleam_stdlib` to MoonBit (`wasm`, `wasm-gc`, `js`, `native`, and Wasm Components).

## Usage

Add both unmodified `gleam_stdlib` and `gekko_stdlib` to your `gleam.toml`:

```toml
[dependencies]
gleam_stdlib = ">= 1.0.0 and < 2.0.0"
gekko_stdlib = { git = "https://github.com/spiral-nights/gekko_stdlib.git", ref = "main" }
```

Then build or test with `gekko` (standard `gleam check` and `gleam test` on Erlang/JS continue to work untouched):

```bash
gekko check
gekko test
gekko build --release
```

## License

MIT — see [`LICENSE`](./LICENSE).
