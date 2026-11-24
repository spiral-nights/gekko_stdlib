# `gekko_stdlib`

Companion MoonBit/Wasm shim overlay package for unmodified upstream [`gleam_stdlib`](https://hex.pm/packages/gleam_stdlib), built for [`gekko`](https://github.com/spiral-nights/gekko).

Instead of forking `gleam_stdlib`, `gekko_stdlib` provides co-located MoonBit module patches (`patches/gleam/**/*.mbt` + `moon.pkg` with `#gekko.patch` attributes) and `[tools.gekko.*]` configuration in `gleam.toml` so upstream `gleam_stdlib` compiles cleanly to MoonBit (`wasm`, `wasm-gc`, `js`, `native`, and Wasm Components).

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

## Testing

Run the local smoke tests on MoonBit:

```bash
gekko test
```

Run the full upstream `gleam_stdlib` parity suite (`1,527` tests across `wasm`, `wasm-gc`, `js`, and `native`) against unmodified Hex `gleam_stdlib`:

```bash
./scripts/test_upstream.sh
```

## License

MIT — see [`LICENSE`](./LICENSE).
