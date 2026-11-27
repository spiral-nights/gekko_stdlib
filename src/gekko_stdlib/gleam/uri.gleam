import gekko_stdlib/ffi/builtin as mbuiltin
import gekko_stdlib/ffi/prelude as mgp
import gekko_stdlib/ffi/utf8 as mutf8
import gleam/list
import gleam/option.{None, Some}

/// @patch("gleam/uri.pop_codeunit")
pub fn pop_codeunit(str: String) -> #(Int, String) {
  case str {
    "" -> #(0, "")
    _ -> #(
      mbuiltin.string_at(str, 0),
      mbuiltin.unsafe_substring(str, 1, mbuiltin.string_length(str)),
    )
  }
}

/// @patch("gleam/uri.codeunit_slice")
pub fn codeunit_slice(str: String, from: Int, length: Int) -> String {
  case length <= 0 {
    True -> ""
    False -> {
      let total = mbuiltin.string_length(str)
      let start = case from < 0 {
        True -> 0
        False -> from
      }
      case start >= total {
        True -> ""
        False -> {
          let raw_end = start + length
          let end = case raw_end > total {
            True -> total
            False -> raw_end
          }
          mbuiltin.unsafe_substring(str, start, end)
        }
      }
    }
  }
}

fn is_unreserved_byte(b: Int) -> Bool {
  { b >= 65 && b <= 90 }
  || { b >= 97 && b <= 122 }
  || { b >= 48 && b <= 57 }
  || b == 45
  || b == 95
  || b == 46
  || b == 126
  || b == 33
  || b == 39
  || b == 40
  || b == 41
  || b == 42
  || b == 43
}

fn hex_digit(n: Int) -> String {
  mbuiltin.unsafe_substring("0123456789ABCDEF", n, n + 1)
}

fn percent_encode_loop(
  bytes: BitArray,
  byte_idx: Int,
  total_bytes: Int,
  buf: mbuiltin.StringBuilder,
) -> Nil {
  case byte_idx >= total_bytes {
    True -> Nil
    False -> {
      let b = case mgp.bit_array_read_int(bytes, byte_idx * 8, 8, False, True) {
        Some(v) -> v
        None -> 0
      }
      case is_unreserved_byte(b) {
        True ->
          case mbuiltin.int32_to_char(b) {
            Some(cp) -> mbuiltin.write_char(buf, cp)
            None -> Nil
          }
        False -> {
          mbuiltin.write_string(buf, "%")
          mbuiltin.write_string(buf, hex_digit(b / 16))
          mbuiltin.write_string(buf, hex_digit(mbuiltin.int64_land(b, 0xF)))
        }
      }
      percent_encode_loop(bytes, byte_idx + 1, total_bytes, buf)
    }
  }
}

/// @patch("gleam/uri.percent_encode")
pub fn percent_encode(value: String) -> String {
  let bytes = mutf8.encode(value, None)
  let total_bytes = mgp.byte_size(bytes)
  let buf = mbuiltin.new_string_builder(None)
  percent_encode_loop(bytes, 0, total_bytes, buf)
  mbuiltin.string_builder_to_string(buf)
}

fn hex_val(b: Int) -> Int {
  case b >= 48 && b <= 57 {
    True -> b - 48
    False ->
      case b >= 97 && b <= 102 {
        True -> b - 97 + 10
        False ->
          case b >= 65 && b <= 70 {
            True -> b - 65 + 10
            False -> -1
          }
      }
  }
}

fn percent_decode_loop(
  bytes: BitArray,
  idx: Int,
  total: Int,
  plus_as_space: Bool,
  acc: List(BitArray),
) -> Result(String, Nil) {
  case idx >= total {
    True ->
      case mutf8.decode(mgp.concat(list.reverse(acc)), None) {
        Ok(s) -> Ok(s)
        Error(_) -> Error(Nil)
      }
    False -> {
      let b = case mgp.bit_array_read_int(bytes, idx * 8, 8, False, True) {
        Some(v) -> v
        None -> 0
      }
      case b == 37 {
        True ->
          case idx + 2 >= total {
            True -> Error(Nil)
            False -> {
              let b1 = case
                mgp.bit_array_read_int(bytes, { idx + 1 } * 8, 8, False, True)
              {
                Some(v) -> v
                None -> -1
              }
              let b2 = case
                mgp.bit_array_read_int(bytes, { idx + 2 } * 8, 8, False, True)
              {
                Some(v) -> v
                None -> -1
              }
              let hi = hex_val(b1)
              let lo = hex_val(b2)
              case hi < 0 || lo < 0 {
                True -> Error(Nil)
                False -> {
                  let out_b = mbuiltin.int64_lor(hi * 16, lo)
                  percent_decode_loop(bytes, idx + 3, total, plus_as_space, [
                    <<out_b:8>>,
                    ..acc
                  ])
                }
              }
            }
          }
        False ->
          case plus_as_space && b == 43 {
            True ->
              percent_decode_loop(bytes, idx + 1, total, plus_as_space, [
                <<32:8>>,
                ..acc
              ])
            False ->
              percent_decode_loop(bytes, idx + 1, total, plus_as_space, [
                <<b:8>>,
                ..acc
              ])
          }
      }
    }
  }
}

fn percent_decode_bytes(
  value: String,
  plus_as_space: Bool,
) -> Result(String, Nil) {
  let bytes = mutf8.encode(value, None)
  let total = mgp.byte_size(bytes)
  percent_decode_loop(bytes, 0, total, plus_as_space, [])
}

/// @patch("gleam/uri.percent_decode")
pub fn percent_decode(value: String) -> Result(String, Nil) {
  percent_decode_bytes(value, False)
}

fn parse_query_part(part: String) -> Result(#(String, String), Nil) {
  let #(raw_k, raw_v) = case mbuiltin.string_split_once(part, "=") {
    Some(pair) -> pair
    None -> #(part, "")
  }
  case percent_decode_bytes(raw_k, True), percent_decode_bytes(raw_v, True) {
    Ok(k), Ok(v) -> Ok(#(k, v))
    _, _ -> Error(Nil)
  }
}

fn parse_query_loop(
  rem: String,
  acc: List(#(String, String)),
) -> Result(List(#(String, String)), Nil) {
  case mbuiltin.string_split_once(rem, "&") {
    Some(#(part, rest)) ->
      case part {
        "" -> parse_query_loop(rest, acc)
        _ ->
          case parse_query_part(part) {
            Ok(kv) -> parse_query_loop(rest, [kv, ..acc])
            Error(_) -> Error(Nil)
          }
      }
    None ->
      case rem {
        "" -> Ok(list.reverse(acc))
        _ ->
          case parse_query_part(rem) {
            Ok(kv) -> Ok(list.reverse([kv, ..acc]))
            Error(_) -> Error(Nil)
          }
      }
  }
}

/// @patch("gleam/uri.parse_query")
pub fn parse_query(query: String) -> Result(List(#(String, String)), Nil) {
  case query {
    "" -> Ok([])
    _ -> parse_query_loop(query, [])
  }
}
