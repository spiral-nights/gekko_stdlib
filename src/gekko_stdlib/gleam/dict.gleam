import gekko_stdlib/ffi/hashmap as mhashmap
import gleam/option.{None, Some}

/// @patch_type("gleam/dict.Dict")
pub type Dict(k, v) =
  mhashmap.HashMap(k, v)

/// @patch_type("gleam/dict.TransientDict")
pub type TransientDict(k, v) =
  Dict(k, v)

/// @patch("gleam/dict.to_transient")
pub fn to_transient(dict: Dict(k, v)) -> TransientDict(k, v) {
  dict
}

/// @patch("gleam/dict.from_transient")
pub fn from_transient(transient: TransientDict(k, v)) -> Dict(k, v) {
  transient
}

/// @patch("gleam/dict.transient_insert")
pub fn transient_insert(
  key: k,
  value: v,
  transient: TransientDict(k, v),
) -> TransientDict(k, v) {
  mhashmap.add(transient, key, value)
}

/// @patch("gleam/dict.transient_delete")
pub fn transient_delete(
  key: k,
  transient: TransientDict(k, v),
) -> TransientDict(k, v) {
  mhashmap.remove(transient, key)
}

/// @patch("gleam/dict.transient_update_with")
pub fn transient_update_with(
  key: k,
  fun: fn(v) -> v,
  init: v,
  transient: TransientDict(k, v),
) -> TransientDict(k, v) {
  let next_val = case mhashmap.get(transient, key) {
    Some(existing) -> fun(existing)
    None -> init
  }
  mhashmap.add(transient, key, next_val)
}

/// @patch("gleam/dict.size")
pub fn size(d: Dict(k, v)) -> Int {
  mhashmap.length(d)
}

/// @patch("gleam/dict.has_key")
pub fn has_key(d: Dict(k, v), key: k) -> Bool {
  mhashmap.contains(d, key)
}

/// @patch("gleam/dict.new")
pub fn new() -> Dict(k, v) {
  mhashmap.new()
}

/// @patch("gleam/dict.get")
pub fn get(from: Dict(k, v), key: k) -> Result(v, Nil) {
  case mhashmap.get(from, key) {
    Some(v) -> Ok(v)
    None -> Error(Nil)
  }
}

/// @patch("gleam/dict.do_insert")
pub fn do_insert(key: k, value: v, d: Dict(k, v)) -> Dict(k, v) {
  mhashmap.add(d, key, value)
}

/// @patch("gleam/dict.delete")
pub fn delete(d: Dict(k, v), key: k) -> Dict(k, v) {
  mhashmap.remove(d, key)
}

/// @patch("gleam/dict.map_values")
pub fn map_values(d: Dict(k, v), fun: fn(k, v) -> a) -> Dict(k, a) {
  mhashmap.map(d, fun)
}

/// @patch("gleam/dict.fold")
pub fn fold(d: Dict(k, v), initial: acc, fun: fn(acc, k, v) -> acc) -> acc {
  mhashmap.fold(d, initial, fun)
}

/// @patch("gleam/dict.do_filter")
pub fn do_filter(f: fn(k, v) -> Bool, d: Dict(k, v)) -> Dict(k, v) {
  mhashmap.filter(d, f)
}
