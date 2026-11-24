#!/usr/bin/env bash
# Transpile and execute upstream gleam-lang/stdlib's test suite through gekko
# against unmodified Hex gleam_stdlib + local gekko_stdlib across MoonBit
# targets (wasm, wasm-gc, js, native).
#
# Environment overrides:
#   GEKKO        - gekko CLI command or binary path (default: gekko)
#   TARGETS      - space-separated MoonBit targets (default: "wasm wasm-gc js native")
#   UPSTREAM_DIR - optional local checkout of gleam-lang/stdlib
#   UPSTREAM_REF - git ref to clone when UPSTREAM_DIR is unset (default: v1.2.0)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GEKKO="${GEKKO:-gekko}"
TARGETS="${TARGETS:-wasm wasm-gc js native}"
UPSTREAM_REF="${UPSTREAM_REF:-v1.2.0}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if [ -n "${UPSTREAM_DIR:-}" ]; then
  UPSTREAM_ROOT="$(cd "$UPSTREAM_DIR" && pwd)"
else
  UPSTREAM_ROOT="$TMP_DIR/upstream_stdlib"
  git clone --depth 1 --branch "$UPSTREAM_REF" https://github.com/gleam-lang/stdlib.git "$UPSTREAM_ROOT" >/dev/null 2>&1
fi

PROJECT_DIR="$TMP_DIR/stdlib_parity"
OUT_DIR="$TMP_DIR/stdlib_parity_mbt"
mkdir -p "$PROJECT_DIR/src" "$PROJECT_DIR/test" "$PROJECT_DIR/moonbit/decode_test_ffi"

cat > "$PROJECT_DIR/gleam.toml" <<EOF
name = "stdlib_parity"
version = "0.1.0"

[dependencies]
gleam_stdlib = ">= 1.0.0 and < 2.0.0"
gekko_stdlib = { path = "$ROOT" }
EOF

cat > "$PROJECT_DIR/src/stdlib_parity.gleam" <<'EOF'
pub fn main() -> Nil {
  Nil
}
EOF

cat > "$PROJECT_DIR/test/stdlib_parity_test.gleam" <<'EOF'
pub fn main() -> Nil {
  Nil
}
EOF

# Pure-Gleam / multi-target upstream stdlib test modules copied verbatim.
verbatim_modules=(
  bit_array_test.gleam
  bool_test.gleam
  bytes_tree_test.gleam
  dict_test.gleam
  dynamic_test.gleam
  float_test.gleam
  function_test.gleam
  list_test.gleam
  option_test.gleam
  order_test.gleam
  pair_test.gleam
  result_test.gleam
  set_test.gleam
  string_tree_test.gleam
  uri_test.gleam
)
for file in "${verbatim_modules[@]}"; do
  cp "$UPSTREAM_ROOT/test/gleam/$file" "$PROJECT_DIR/test/$file"
done

# int_test.gleam: skip the single `bitwise_shift_edge_cases_test` function
# because it uses the literal `9_223_372_036_854_775_808` (2^63), which exceeds
# signed 64-bit `Int64::MAX` (gekko rejects out-of-range Int literals at compile time).
awk '
  BEGIN { skip = 0; found = 0 }
  $0 == "pub fn bitwise_shift_edge_cases_test() {" {
    skip = 1
    found = 1
    next
  }
  skip && $0 == "}" {
    skip = 0
    next
  }
  !skip { print }
  END {
    if (!found) {
      print "FAIL: expected bitwise_shift_edge_cases_test() in int_test.gleam" > "/dev/stderr"
      exit 1
    }
  }
' "$UPSTREAM_ROOT/test/gleam/int_test.gleam" > "$PROJECT_DIR/test/int_test.gleam"

# string_test.gleam: skip the `@target(erlang)` BEAM inspect tests (which bind
# Erlang `self()` / `make_ref()` and test Erlang PIDs/references/improper lists).
awk '
  BEGIN { skip = 0; imp_count = 0; found_erl = 0; found_js = 0 }
  !skip && $0 == "@target(erlang)" {
    if ((getline next_line) > 0) {
      if (next_line == "import gleam/int" || next_line == "import gleam/list" || next_line == "import gleam/result") {
        imp_count++
        next
      }
      if (next_line == "@external(erlang, \"erlang\", \"self\")") {
        found_erl = 1
        skip = 1
        next
      }
      print $0
      print next_line
      next
    }
    print $0
    next
  }
  skip && $0 == "@target(javascript)" {
    if ((getline next_line) > 0) {
      if (next_line == "@external(javascript, \"../gleam_stdlib_test_ffi.mjs\", \"circular_reference\")") {
        found_js = 1
        skip = 0
        print $0
        print next_line
        next
      }
    }
    next
  }
  !skip { print }
  END {
    if (imp_count != 3 || !found_erl || !found_js) {
      print "FAIL: expected Erlang test markers not found in string_test.gleam" > "/dev/stderr"
      exit 1
    }
  }
' "$UPSTREAM_ROOT/test/gleam/string_test.gleam" > "$PROJECT_DIR/test/string_test.gleam"

# dynamic/decode_test.gleam: copied verbatim alongside a tiny test-only MoonBit
# FFI override for its Erlang/JS `make_object` / `make_map` test helpers.
cp "$UPSTREAM_ROOT/test/gleam/dynamic/decode_test.gleam" "$PROJECT_DIR/test/decode_test.gleam"

cat > "$PROJECT_DIR/moonbit/decode_test_ffi/moon.pkg" <<'EOF'
import {
  "stdlib_parity/gprelude" @gprelude,
}
EOF

cat > "$PROJECT_DIR/moonbit/decode_test_ffi/decode_test_ffi.mbt" <<'EOF'
///|
pub fn[T : @gprelude.ToDynamic] make_map(
  items : @gprelude.GList[(String, T)],
) -> @gprelude.Dynamic {
  let m : Map[@gprelude.Dynamic, @gprelude.Dynamic] = Default::default()
  for cur = items {
    match cur {
      @gprelude.Nil => break @gprelude.DynMap(m)
      @gprelude.Cons((k, v), rest) => {
        m.set(@gprelude.DynString(k), @gprelude.ToDynamic::to_dynamic(v))
        continue rest
      }
    }
  }
}
EOF

cat >> "$PROJECT_DIR/gleam.toml" <<'EOF'

[tools.gekko.use_shims]
gleam_stdlib = "gekko_stdlib"
EOF

mkdir -p "$PROJECT_DIR/patches/test/decode_test"
cat > "$PROJECT_DIR/patches/test/decode_test/moon.pkg" <<'EOF'
import {
  "decode_test_ffi",
}
EOF

cat > "$PROJECT_DIR/patches/test/decode_test/decode_test.mbt" <<'EOF'
///|
#gekko.patch
fn[T : @gprelude.ToDynamic] make_object(
  items : @gprelude.GList[(String, T)],
) -> @gprelude.Dynamic {
  @decode_test_ffi.make_map(items)
}

///|
#gekko.patch
fn[T : @gprelude.ToDynamic] make_map(
  items : @gprelude.GList[(String, T)],
) -> @gprelude.Dynamic {
  @decode_test_ffi.make_map(items)
}
EOF

echo "=== Staging dependencies and transpiling stdlib_parity ==="
(cd "$PROJECT_DIR" && gleam deps download)
if ! gekko_out="$("$GEKKO" check --root "$PROJECT_DIR" --out "$OUT_DIR" --target wasm 2>&1)"; then
  echo "$gekko_out" >&2
  exit 1
fi
echo "$gekko_out"
if echo "$gekko_out" | grep -qi "warning"; then
  echo "FAIL: gekko check emitted warnings for stdlib_parity" >&2
  exit 1
fi

for target in $TARGETS; do
  echo "=== Running stdlib_parity tests on $target ==="
  (cd "$OUT_DIR" && moon check --deny-warn --target "$target")
  if ! out="$(cd "$OUT_DIR" && moon test --target "$target" 2>&1)"; then
    echo "$out" >&2
    exit 1
  fi
  echo "$out"
  case "$out" in
    *"passed: 1527, failed: 0"*) ;;
    *)
      echo "FAIL [stdlib_parity/$target]: expected 'passed: 1527, failed: 0'" >&2
      exit 1
      ;;
  esac
done

echo "gleam_stdlib MoonBit parity tests passed on all targets ($TARGETS)."
