import gekko_stdlib/ffi/builtin as mbuiltin
import gekko_stdlib/ffi/math as mmath
import gekko_stdlib/ffi/mstring
import gekko_stdlib/ffi/random as mrandom
import gleam/option.{None, Some}

/// @patch("gleam/float.do_to_float")
pub fn do_to_float(x: Int) -> Float {
  mbuiltin.int64_to_double(x)
}

/// @patch("gleam/float.parse")
pub fn parse(s: String) -> Result(Float, Nil) {
  case mbuiltin.string_contains(s, ".") {
    False -> Error(Nil)
    True ->
      case mstring.parse_double(s) {
        Ok(f) -> Ok(f)
        Error(_) -> Error(Nil)
      }
  }
}

/// @patch("gleam/float.to_string")
pub fn to_string(x: Float) -> String {
  let raw =
    mbuiltin.double_to_string(x)
    |> mbuiltin.string_replace_all("+", "")
    |> mbuiltin.string_replace_all("E", "e")
  case mbuiltin.string_contains(raw, ".") {
    True -> raw
    False ->
      case mbuiltin.string_find(raw, "e") {
        Some(idx) ->
          mbuiltin.unsafe_substring(raw, 0, idx)
          <> ".0"
          <> mbuiltin.unsafe_substring(raw, idx, mbuiltin.string_length(raw))
        None ->
          case raw != "NaN" && raw != "Infinity" && raw != "-Infinity" {
            True -> raw <> ".0"
            False -> raw
          }
      }
  }
}

/// @patch("gleam/float.ceiling")
pub fn ceiling(x: Float) -> Float {
  mmath.ceil(x)
}

/// @patch("gleam/float.floor")
pub fn floor(x: Float) -> Float {
  mmath.floor(x)
}

/// @patch("gleam/float.round")
pub fn round(x: Float) -> Int {
  let t = mmath.trunc(x)
  let frac = x -. t
  case frac >=. 0.5 {
    True -> mbuiltin.double_to_int64(t +. 1.0)
    False ->
      case frac <=. -0.5 {
        True -> mbuiltin.double_to_int64(t -. 1.0)
        False -> mbuiltin.double_to_int64(t)
      }
  }
}

/// @patch("gleam/float.truncate")
pub fn truncate(x: Float) -> Int {
  mbuiltin.double_to_int64(mmath.trunc(x))
}

/// @patch("gleam/float.do_power")
pub fn do_power(base: Float, exponent: Float) -> Float {
  mmath.pow(base, exponent)
}

/// @patch("gleam/float.random")
pub fn random() -> Float {
  mrandom.double(Some(0.0), Some(1.0))
}

/// @patch("gleam/float.do_log")
pub fn do_log(x: Float) -> Float {
  mmath.ln(x)
}

/// @patch("gleam/float.exponential")
pub fn exponential(x: Float) -> Float {
  mmath.exp(x)
}
