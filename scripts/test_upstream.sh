#!/usr/bin/env bash
# Transpile and execute upstream gleam-lang/stdlib's test suite through gekko
# against unmodified Hex gleam_stdlib + local gekko_stdlib across MoonBit
# targets (wasm, wasm-gc, js, native).
#
# Environment overrides:
#   GEKKO           - gekko CLI command or binary path (default: gekko)
#   TARGETS         - space-separated MoonBit targets (default: "wasm wasm-gc js native")
#   UPSTREAM_DIR    - optional local checkout of gleam-lang/stdlib
#   UPSTREAM_REF    - git ref to clone when UPSTREAM_DIR is unset (default: v1.2.0)
#   GEKKO_CACHE_DIR - optional persistent cache directory for clones, staging, and MoonBit builds
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GEKKO="${GEKKO:-gekko}"
TARGETS="${TARGETS:-wasm wasm-gc js native}"
UPSTREAM_REF="${UPSTREAM_REF:-v1.2.0}"
GEKKO_CACHE_DIR="${GEKKO_CACHE_DIR:-}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

LAST_CHANGED=0

write_if_changed() {
  local dest="$1"
  local tmp_file
  tmp_file="$(mktemp "$TMP_DIR/wic.XXXXXX")"
  cat > "$tmp_file"
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ] && cmp -s "$tmp_file" "$dest"; then
    rm -f "$tmp_file"
    LAST_CHANGED=0
  else
    mv "$tmp_file" "$dest"
    LAST_CHANGED=1
  fi
}

copy_if_changed() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    LAST_CHANGED=0
  else
    cp "$src" "$dest"
    LAST_CHANGED=1
  fi
}

if [ -n "${UPSTREAM_DIR:-}" ]; then
  UPSTREAM_ROOT="$(cd "$UPSTREAM_DIR" && pwd)"
elif [ -n "$GEKKO_CACHE_DIR" ]; then
  UPSTREAM_ROOT="$GEKKO_CACHE_DIR/upstream/stdlib-$UPSTREAM_REF"
  if [ ! -d "$UPSTREAM_ROOT/.git" ]; then
    mkdir -p "$(dirname "$UPSTREAM_ROOT")"
    git clone --depth 1 --branch "$UPSTREAM_REF" https://github.com/gleam-lang/stdlib.git "$TMP_DIR/upstream_stdlib" >/dev/null 2>&1
    rm -rf "$UPSTREAM_ROOT"
    mv "$TMP_DIR/upstream_stdlib" "$UPSTREAM_ROOT"
  fi
else
  UPSTREAM_ROOT="$TMP_DIR/upstream_stdlib"
  git clone --depth 1 --branch "$UPSTREAM_REF" https://github.com/gleam-lang/stdlib.git "$UPSTREAM_ROOT" >/dev/null 2>&1
fi

if [ -n "$GEKKO_CACHE_DIR" ]; then
  PROJECT_DIR="$GEKKO_CACHE_DIR/stdlib_parity/project"
  OUT_DIR="$GEKKO_CACHE_DIR/stdlib_parity/out"
else
  PROJECT_DIR="$TMP_DIR/stdlib_parity"
  OUT_DIR="$TMP_DIR/stdlib_parity_mbt"
fi
mkdir -p "$PROJECT_DIR/src" "$PROJECT_DIR/test" "$PROJECT_DIR/moonbit/decode_test_ffi"

GLEAM_TOML_CHANGED=0
write_if_changed "$PROJECT_DIR/gleam.toml" <<EOF
name = "stdlib_parity"
version = "0.1.0"

[dependencies]
gleam_stdlib = ">= 1.0.0 and < 2.0.0"
gekko_stdlib = { path = "$ROOT" }

[tools.gekko.use_shims]
gleam_stdlib = "gekko_stdlib"
EOF
GLEAM_TOML_CHANGED=$LAST_CHANGED

write_if_changed "$PROJECT_DIR/src/stdlib_parity.gleam" <<'EOF'
pub fn main() -> Nil {
  Nil
}
EOF

write_if_changed "$PROJECT_DIR/test/stdlib_parity_test.gleam" <<'EOF'
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
  copy_if_changed "$UPSTREAM_ROOT/test/gleam/$file" "$PROJECT_DIR/test/$file"
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
' "$UPSTREAM_ROOT/test/gleam/int_test.gleam" | write_if_changed "$PROJECT_DIR/test/int_test.gleam"

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
' "$UPSTREAM_ROOT/test/gleam/string_test.gleam" | write_if_changed "$PROJECT_DIR/test/string_test.gleam"

# dynamic/decode_test.gleam: copied verbatim alongside a pure-Gleam test-only
# @patch override for its Erlang/JS `make_object` / `make_map` test helpers.
copy_if_changed "$UPSTREAM_ROOT/test/gleam/dynamic/decode_test.gleam" "$PROJECT_DIR/test/decode_test.gleam"

write_if_changed "$PROJECT_DIR/src/decode_test_shim.gleam" <<'EOF'
import gekko_stdlib/ffi/prelude as mgp
import gleam/dynamic.{type Dynamic}
import gleam/list

/// @patch("test/decode_test.make_object")
/// @patch("test/decode_test.make_map")
pub fn make_map(items: List(#(String, a))) -> Dynamic {
  items
  |> list.map(fn(p) { #(dynamic.string(p.0), mgp.to_dynamic(p.1)) })
  |> dynamic.properties
}
EOF

echo "=== Staging dependencies and transpiling stdlib_parity ==="
if [ ! -d "$PROJECT_DIR/build/packages/gleam_stdlib" ] || [ "$GLEAM_TOML_CHANGED" -eq 1 ]; then
  rm -f "$PROJECT_DIR/manifest.toml"
  (cd "$PROJECT_DIR" && gleam deps download)
fi

FIRST_TARGET="${TARGETS%% *}"
if ! gekko_out="$("$GEKKO" check --root "$PROJECT_DIR" --out "$OUT_DIR" --target "$FIRST_TARGET" 2>&1)"; then
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
  if ! out="$(cd "$OUT_DIR" && moon test --deny-warn --target "$target" 2>&1)"; then
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
