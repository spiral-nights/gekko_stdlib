import gekko_stdlib/ffi/builtin as mbuiltin
import gekko_stdlib/ffi/prelude as mgp
import gleam/dynamic.{type Dynamic}
import gleam/option.{None}

/// @patch("gleam/dynamic.classify")
pub fn classify(data: Dynamic) -> String {
  mgp.match_dynamic(
    data,
    fn() { "Nil" },
    fn(_) { "Bool" },
    fn(_) { "Int" },
    fn(_) { "Float" },
    fn(_) { "String" },
    fn(_) { "BitArray" },
    fn(_) { "List" },
    fn(_) { "Array" },
    fn(_) { "Dict" },
  )
}

/// @patch("gleam/dynamic.bool")
pub fn bool(a: Bool) -> Dynamic {
  mgp.dynamic_dyn_bool(a)
}

/// @patch("gleam/dynamic.string")
pub fn string(a: String) -> Dynamic {
  mgp.dynamic_dyn_string(a)
}

/// @patch("gleam/dynamic.float")
pub fn float(a: Float) -> Dynamic {
  mgp.dynamic_dyn_float(a)
}

/// @patch("gleam/dynamic.int")
pub fn int(a: Int) -> Dynamic {
  mgp.dynamic_dyn_int(a)
}

/// @patch("gleam/dynamic.bit_array")
pub fn bit_array(a: BitArray) -> Dynamic {
  mgp.dynamic_dyn_bit_array(a)
}

/// @patch("gleam/dynamic.list")
pub fn list(a: List(Dynamic)) -> Dynamic {
  mgp.dynamic_dyn_list(a)
}

/// @patch("gleam/dynamic.array")
pub fn array(a: List(Dynamic)) -> Dynamic {
  mgp.dynamic_dyn_array(a)
}

/// @patch("gleam/dynamic.properties")
pub fn properties(entries: List(#(Dynamic, Dynamic))) -> Dynamic {
  mgp.dynamic_dyn_map(mbuiltin.new_map(entries, None))
}

/// @patch("gleam/dynamic.nil")
pub fn nil() -> Dynamic {
  mgp.dynamic_dyn_null()
}
