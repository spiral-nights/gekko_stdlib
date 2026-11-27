import gekko_stdlib/ffi/hashmap as mhashmap
import gleam/dict.{type Dict}
import gleam/option.{None, Some}

fn fold_list(xs: List(a), acc: b, fun: fn(b, a) -> b) -> b {
  case xs {
    [] -> acc
    [h, ..t] -> fold_list(t, fun(acc, h), fun)
  }
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

/// @patch("gleam/dict.from_list")
pub fn from_list(entries: List(#(k, v))) -> Dict(k, v) {
  fold_list(entries, dict.new(), fn(acc, pair) {
    dict.insert(acc, pair.0, pair.1)
  })
}

/// @patch("gleam/dict.do_filter")
pub fn do_filter(f: fn(k, v) -> Bool, d: Dict(k, v)) -> Dict(k, v) {
  mhashmap.filter(d, f)
}

/// @patch("gleam/dict.do_take")
pub fn do_take(desired_keys: List(k), d: Dict(k, v)) -> Dict(k, v) {
  fold_list(desired_keys, dict.new(), fn(acc, k) {
    case dict.get(d, k) {
      Ok(v) -> dict.insert(acc, k, v)
      Error(_) -> acc
    }
  })
}

/// @patch("gleam/dict.do_drop")
pub fn do_drop(disallowed_keys: List(k), d: Dict(k, v)) -> Dict(k, v) {
  fold_list(disallowed_keys, d, dict.delete)
}

/// @patch("gleam/dict.do_combine")
pub fn do_combine(
  combine_fn: fn(k, v, v) -> v,
  left: Dict(k, v),
  right: Dict(k, v),
) -> Dict(k, v) {
  dict.fold(right, left, fn(acc, k, r_val) {
    case dict.get(acc, k) {
      Ok(l_val) -> dict.insert(acc, k, combine_fn(k, l_val, r_val))
      Error(_) -> dict.insert(acc, k, r_val)
    }
  })
}

/// @patch("gleam/dict.group")
pub fn group(key: fn(v) -> k, items: List(v)) -> Dict(k, List(v)) {
  fold_list(items, dict.new(), fn(acc, v) {
    let k = key(v)
    case dict.get(acc, k) {
      Ok(existing) -> dict.insert(acc, k, [v, ..existing])
      Error(_) -> dict.insert(acc, k, [v])
    }
  })
}
