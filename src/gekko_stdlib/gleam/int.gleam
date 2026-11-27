import gekko_stdlib/ffi/builtin as mbuiltin
import gleam/option.{None}

/// @patch("gleam/int.parse")
pub fn parse(s: String) -> Result(Int, Nil) {
  do_base_parse(s, 10)
}

fn char_digit(code: Int) -> Int {
  case code >= 48 && code <= 57 {
    True -> code - 48
    False ->
      case code >= 97 && code <= 122 {
        True -> code - 97 + 10
        False ->
          case code >= 65 && code <= 90 {
            True -> code - 65 + 10
            False -> -1
          }
      }
  }
}

fn parse_digits_loop(
  chars: List(UtfCodepoint),
  base: Int,
  sign: Int,
  acc: Int,
) -> Result(Int, Nil) {
  case chars {
    [] -> Ok(acc)
    [c, ..rest] -> {
      let digit = char_digit(mbuiltin.char_to_int(c))
      case digit < 0 || digit >= base {
        True -> Error(Nil)
        False -> parse_digits_loop(rest, base, sign, acc * base + sign * digit)
      }
    }
  }
}

/// @patch("gleam/int.do_base_parse")
pub fn do_base_parse(s: String, base: Int) -> Result(Int, Nil) {
  case base < 2 || base > 36 || s == "" {
    True -> Error(Nil)
    False ->
      case mbuiltin.string_to_array(s) {
        [] -> Error(Nil)
        [first, ..rest] -> {
          let code = mbuiltin.char_to_int(first)
          let #(sign, digits) = case code == 45, code == 43 {
            True, _ -> #(-1, rest)
            False, True -> #(1, rest)
            False, False -> #(1, [first, ..rest])
          }
          case digits {
            [] -> Error(Nil)
            _ -> parse_digits_loop(digits, base, sign, 0)
          }
        }
      }
  }
}

/// @patch("gleam/int.to_string")
pub fn to_string(x: Int) -> String {
  mbuiltin.int64_to_string(x, None)
}

fn digit_char(d: Int) -> String {
  mbuiltin.unsafe_substring("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", d, d + 1)
}

fn base_digits_loop(n: Int, base: Int, rev: List(String)) -> List(String) {
  case n == 0 {
    True -> rev
    False -> {
      let rem = n % base
      let d = case rem < 0 {
        True -> -rem
        False -> rem
      }
      base_digits_loop(n / base, base, [digit_char(d), ..rev])
    }
  }
}

fn write_digits(buf: mbuiltin.StringBuilder, digits: List(String)) -> Nil {
  case digits {
    [] -> Nil
    [d, ..rest] -> {
      mbuiltin.write_string(buf, d)
      write_digits(buf, rest)
    }
  }
}

/// @patch("gleam/int.do_to_base_string")
pub fn do_to_base_string(x: Int, base: Int) -> String {
  case base < 2 || base > 36 {
    True -> ""
    False ->
      case x == 0 {
        True -> "0"
        False -> {
          let digits = base_digits_loop(x, base, [])
          let buf = mbuiltin.new_string_builder(None)
          case x < 0 {
            True -> mbuiltin.write_string(buf, "-")
            False -> Nil
          }
          write_digits(buf, digits)
          mbuiltin.string_builder_to_string(buf)
        }
      }
  }
}

/// @patch("gleam/int.to_float")
pub fn to_float(x: Int) -> Float {
  mbuiltin.int64_to_double(x)
}

/// @patch("gleam/int.bitwise_and")
pub fn bitwise_and(x: Int, y: Int) -> Int {
  mbuiltin.int64_land(x, y)
}

/// @patch("gleam/int.bitwise_not")
pub fn bitwise_not(x: Int) -> Int {
  mbuiltin.int64_lnot(x)
}

/// @patch("gleam/int.bitwise_or")
pub fn bitwise_or(x: Int, y: Int) -> Int {
  mbuiltin.int64_lor(x, y)
}

/// @patch("gleam/int.bitwise_exclusive_or")
pub fn bitwise_exclusive_or(x: Int, y: Int) -> Int {
  mbuiltin.int64_lxor(x, y)
}

fn shl_pos(x: Int, k: Int) -> Int {
  case k <= 0 {
    True -> x
    False -> shl_pos(x + x, k - 1)
  }
}

fn asr_pos(x: Int, k: Int) -> Int {
  case k <= 0 {
    True -> x
    False -> {
      let next = case x >= 0 {
        True -> x / 2
        False -> {
          let q = x / 2
          case q * 2 == x {
            True -> q
            False -> q - 1
          }
        }
      }
      asr_pos(next, k - 1)
    }
  }
}

/// @patch("gleam/int.bitwise_shift_left")
pub fn bitwise_shift_left(x: Int, y: Int) -> Int {
  case y < 0 {
    True ->
      case y <= -64 {
        True ->
          case x < 0 {
            True -> -1
            False -> 0
          }
        False -> asr_pos(x, -y)
      }
    False ->
      case y >= 64 {
        True -> 0
        False -> shl_pos(x, y)
      }
  }
}

/// @patch("gleam/int.bitwise_shift_right")
pub fn bitwise_shift_right(x: Int, y: Int) -> Int {
  case y < 0 {
    True ->
      case y <= -64 {
        True -> 0
        False -> shl_pos(x, -y)
      }
    False ->
      case y >= 64 {
        True ->
          case x < 0 {
            True -> -1
            False -> 0
          }
        False -> asr_pos(x, y)
      }
  }
}
