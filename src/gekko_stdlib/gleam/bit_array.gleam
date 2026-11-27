import gekko_stdlib/ffi/builtin as mbuiltin
import gekko_stdlib/ffi/prelude as mgp
import gekko_stdlib/ffi/utf8 as mutf8
import gleam/option.{None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}

fn reverse_list(xs: List(a), acc: List(a)) -> List(a) {
  case xs {
    [] -> acc
    [h, ..t] -> reverse_list(t, [h, ..acc])
  }
}

/// @patch("gleam/bit_array.from_string")
pub fn from_string(x: String) -> BitArray {
  mgp.from_string(x)
}

/// @patch("gleam/bit_array.bit_size")
pub fn bit_size(x: BitArray) -> Int {
  mgp.bit_size(x)
}

/// @patch("gleam/bit_array.byte_size")
pub fn byte_size(x: BitArray) -> Int {
  mgp.byte_size(x)
}

/// @patch("gleam/bit_array.pad_to_bytes")
pub fn pad_to_bytes(x: BitArray) -> BitArray {
  mgp.pad_to_bytes(x)
}

/// @patch("gleam/bit_array.slice")
pub fn slice(bits: BitArray, at: Int, take: Int) -> Result(BitArray, Nil) {
  let total_bits = mgp.bit_size(bits)
  case total_bits % 8 != 0 || at < 0 {
    True -> Error(Nil)
    False -> {
      let len = total_bits / 8
      let #(start, count) = case take < 0 {
        True -> #(at + take, -take)
        False -> #(at, take)
      }
      case start < 0 || start + count > len {
        True -> Error(Nil)
        False ->
          case count == 0 {
            True -> Ok(<<>>)
            False ->
              case mgp.bit_array_read_bits(bits, start * 8, count * 8) {
                Some(v) -> Ok(v)
                None -> Error(Nil)
              }
          }
      }
    }
  }
}

/// @patch("gleam/bit_array.is_utf8")
pub fn is_utf8(bits: BitArray) -> Bool {
  case mgp.bit_size(bits) % 8 == 0 {
    False -> False
    True ->
      case mutf8.decode(bits, None) {
        Ok(_) -> True
        Error(_) -> False
      }
  }
}

/// @patch("gleam/bit_array.to_string")
pub fn to_string(bits: BitArray) -> Result(String, Nil) {
  case mgp.bit_size(bits) % 8 == 0 {
    False -> Error(Nil)
    True ->
      case mutf8.decode(bits, None) {
        Ok(s) -> Ok(s)
        Error(_) -> Error(Nil)
      }
  }
}

/// @patch("gleam/bit_array.concat")
pub fn concat(bit_arrays: List(BitArray)) -> BitArray {
  mgp.concat(bit_arrays)
}

fn read_byte(ba: BitArray, offset: Int) -> Int {
  case mgp.bit_array_read_int(ba, offset, 8, False, True) {
    Some(b) -> b
    None -> 0
  }
}

fn b64_char(idx: Int) -> String {
  mbuiltin.unsafe_substring(
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
    idx,
    idx + 1,
  )
}

fn base64_loop(
  data: BitArray,
  byte_idx: Int,
  total_bytes: Int,
  padding: Bool,
  buf: mbuiltin.StringBuilder,
) -> Nil {
  case byte_idx >= total_bytes {
    True -> Nil
    False -> {
      let off = byte_idx * 8
      let b0 = read_byte(data, off)
      let has1 = byte_idx + 1 < total_bytes
      let has2 = byte_idx + 2 < total_bytes
      let b1 = case has1 {
        True -> read_byte(data, off + 8)
        False -> 0
      }
      let b2 = case has2 {
        True -> read_byte(data, off + 16)
        False -> 0
      }
      let triple =
        mbuiltin.int64_lor(mbuiltin.int64_lor(b0 * 65_536, b1 * 256), b2)
      let c0 = mbuiltin.int64_land(triple / 262_144, 0x3F)
      let c1 = mbuiltin.int64_land(triple / 4096, 0x3F)
      mbuiltin.write_string(buf, b64_char(c0))
      mbuiltin.write_string(buf, b64_char(c1))
      case has1 {
        True -> {
          let c2 = mbuiltin.int64_land(triple / 64, 0x3F)
          mbuiltin.write_string(buf, b64_char(c2))
        }
        False ->
          case padding {
            True -> mbuiltin.write_string(buf, "=")
            False -> Nil
          }
      }
      case has2 {
        True -> {
          let c3 = mbuiltin.int64_land(triple, 0x3F)
          mbuiltin.write_string(buf, b64_char(c3))
        }
        False ->
          case padding {
            True -> mbuiltin.write_string(buf, "=")
            False -> Nil
          }
      }
      base64_loop(data, byte_idx + 3, total_bytes, padding, buf)
    }
  }
}

/// @patch("gleam/bit_array.base64_encode")
pub fn base64_encode(input: BitArray, padding: Bool) -> String {
  let padded = mgp.pad_to_bytes(input)
  let total_bytes = mgp.byte_size(padded)
  let buf = mbuiltin.new_string_builder(None)
  base64_loop(padded, 0, total_bytes, padding, buf)
  mbuiltin.string_builder_to_string(buf)
}

fn b64_val(code: Int) -> Int {
  case code >= 65 && code <= 90 {
    True -> code - 65
    False ->
      case code >= 97 && code <= 122 {
        True -> code - 97 + 26
        False ->
          case code >= 48 && code <= 57 {
            True -> code - 48 + 52
            False ->
              case code == 43 {
                True -> 62
                False ->
                  case code == 47 {
                    True -> 63
                    False -> -1
                  }
              }
          }
      }
  }
}

fn decode64_loop(
  chars: List(UtfCodepoint),
  acc: List(BitArray),
) -> Result(BitArray, Nil) {
  case chars {
    [] -> Ok(mgp.concat(reverse_list(acc, [])))
    [ch0, ch1, ch2, ch3, ..rest] -> {
      let c0 = mbuiltin.char_to_int(ch0)
      let c1 = mbuiltin.char_to_int(ch1)
      let c2 = mbuiltin.char_to_int(ch2)
      let c3 = mbuiltin.char_to_int(ch3)
      let v0 = b64_val(c0)
      let v1 = b64_val(c1)
      case v0 < 0 || v1 < 0 {
        True -> Error(Nil)
        False -> {
          let is_last = rest == []
          case c2 == 61 {
            True ->
              case !is_last || c3 != 61 {
                True -> Error(Nil)
                False -> {
                  let b0 = mbuiltin.int64_lor(v0 * 4, v1 / 16)
                  decode64_loop(rest, [<<b0:8>>, ..acc])
                }
              }
            False ->
              case c3 == 61 {
                True ->
                  case !is_last {
                    True -> Error(Nil)
                    False -> {
                      let v2 = b64_val(c2)
                      case v2 < 0 {
                        True -> Error(Nil)
                        False -> {
                          let b0 = mbuiltin.int64_lor(v0 * 4, v1 / 16)
                          let b1 =
                            mbuiltin.int64_lor(
                              mbuiltin.int64_land(v1, 0xF) * 16,
                              v2 / 4,
                            )
                          decode64_loop(rest, [<<b0:8, b1:8>>, ..acc])
                        }
                      }
                    }
                  }
                False -> {
                  let v2 = b64_val(c2)
                  let v3 = b64_val(c3)
                  case v2 < 0 || v3 < 0 {
                    True -> Error(Nil)
                    False -> {
                      let b0 = mbuiltin.int64_lor(v0 * 4, v1 / 16)
                      let b1 =
                        mbuiltin.int64_lor(
                          mbuiltin.int64_land(v1, 0xF) * 16,
                          v2 / 4,
                        )
                      let b2 =
                        mbuiltin.int64_lor(
                          mbuiltin.int64_land(v2, 0x3) * 64,
                          v3,
                        )
                      decode64_loop(rest, [<<b0:8, b1:8, b2:8>>, ..acc])
                    }
                  }
                }
              }
          }
        }
      }
    }
    _ -> Error(Nil)
  }
}

/// @patch("gleam/bit_array.decode64")
pub fn decode64(input: String) -> Result(BitArray, Nil) {
  case input {
    "" -> Ok(<<>>)
    _ -> decode64_loop(mbuiltin.string_to_array(input), [])
  }
}

fn hex_char(idx: Int) -> String {
  mbuiltin.unsafe_substring("0123456789ABCDEF", idx, idx + 1)
}

fn base16_encode_loop(
  data: BitArray,
  byte_idx: Int,
  total_bytes: Int,
  buf: mbuiltin.StringBuilder,
) -> Nil {
  case byte_idx >= total_bytes {
    True -> Nil
    False -> {
      let b = read_byte(data, byte_idx * 8)
      mbuiltin.write_string(buf, hex_char(b / 16))
      mbuiltin.write_string(buf, hex_char(mbuiltin.int64_land(b, 0xF)))
      base16_encode_loop(data, byte_idx + 1, total_bytes, buf)
    }
  }
}

/// @patch("gleam/bit_array.base16_encode")
pub fn base16_encode(input: BitArray) -> String {
  let padded = mgp.pad_to_bytes(input)
  let total_bytes = mgp.byte_size(padded)
  let buf = mbuiltin.new_string_builder(None)
  base16_encode_loop(padded, 0, total_bytes, buf)
  mbuiltin.string_builder_to_string(buf)
}

fn hex_val(code: Int) -> Int {
  case code >= 48 && code <= 57 {
    True -> code - 48
    False ->
      case code >= 97 && code <= 102 {
        True -> code - 97 + 10
        False ->
          case code >= 65 && code <= 70 {
            True -> code - 65 + 10
            False -> -1
          }
      }
  }
}

fn base16_decode_loop(
  chars: List(UtfCodepoint),
  acc: List(BitArray),
) -> Result(BitArray, Nil) {
  case chars {
    [] -> Ok(mgp.concat(reverse_list(acc, [])))
    [c0, c1, ..rest] -> {
      let hi = hex_val(mbuiltin.char_to_int(c0))
      let lo = hex_val(mbuiltin.char_to_int(c1))
      case hi < 0 || lo < 0 {
        True -> Error(Nil)
        False -> {
          let b = mbuiltin.int64_lor(hi * 16, lo)
          base16_decode_loop(rest, [<<b:8>>, ..acc])
        }
      }
    }
    _ -> Error(Nil)
  }
}

/// @patch("gleam/bit_array.base16_decode")
pub fn base16_decode(input: String) -> Result(BitArray, Nil) {
  base16_decode_loop(mbuiltin.string_to_array(input), [])
}

/// @patch("gleam/bit_array.inspect")
pub fn inspect(input: BitArray) -> String {
  mgp.gleam_inspect(input)
}

fn any_nonzero_bits(ba: BitArray, off: Int, count: Int) -> Bool {
  case count <= 0 {
    True -> False
    False -> {
      let step = case count >= 8 {
        True -> 8
        False -> count
      }
      case mgp.bit_array_read_int(ba, off, step, False, True) {
        Some(v) if v != 0 -> True
        _ -> any_nonzero_bits(ba, off + step, count - step)
      }
    }
  }
}

fn compare_tail_val(ba: BitArray, off: Int, rem_bits: Int) -> Int {
  case rem_bits < 8 {
    True ->
      case mgp.bit_array_read_int(ba, off, rem_bits, False, True) {
        Some(v) -> v
        None -> 0
      }
    False -> {
      let high_bits = rem_bits - 7
      case any_nonzero_bits(ba, off, high_bits) {
        True -> 256
        False ->
          case mgp.bit_array_read_int(ba, off + high_bits, 7, False, True) {
            Some(v) -> v
            None -> 0
          }
      }
    }
  }
}

fn compare_loop(
  a: BitArray,
  b: BitArray,
  off: Int,
  len_a: Int,
  len_b: Int,
) -> Order {
  let rem_a = len_a - off
  let rem_b = len_b - off
  case rem_a >= 8 && rem_b >= 8 {
    True -> {
      let va = read_byte(a, off)
      let vb = read_byte(b, off)
      case va < vb {
        True -> Lt
        False ->
          case va > vb {
            True -> Gt
            False -> compare_loop(a, b, off + 8, len_a, len_b)
          }
      }
    }
    False ->
      case rem_a == 0 && rem_b == 0 {
        True -> Eq
        False ->
          case rem_b == 0 {
            True -> Gt
            False ->
              case rem_a == 0 {
                True -> Lt
                False -> {
                  let va = compare_tail_val(a, off, rem_a)
                  let vb = compare_tail_val(b, off, rem_b)
                  case va < vb {
                    True -> Lt
                    False ->
                      case va > vb {
                        True -> Gt
                        False ->
                          case rem_a > rem_b {
                            True -> Gt
                            False ->
                              case rem_a < rem_b {
                                True -> Lt
                                False -> Eq
                              }
                          }
                      }
                  }
                }
              }
          }
      }
  }
}

/// @patch("gleam/bit_array.compare")
pub fn compare(a: BitArray, b: BitArray) -> Order {
  compare_loop(a, b, 0, mgp.bit_size(a), mgp.bit_size(b))
}

fn starts_with_loop(
  bits: BitArray,
  prefix: BitArray,
  off: Int,
  pref_len: Int,
) -> Bool {
  case off >= pref_len {
    True -> True
    False -> {
      let step = case pref_len - off >= 8 {
        True -> 8
        False -> pref_len - off
      }
      case
        mgp.bit_array_read_int(bits, off, step, False, True),
        mgp.bit_array_read_int(prefix, off, step, False, True)
      {
        Some(a), Some(b) if a == b ->
          starts_with_loop(bits, prefix, off + step, pref_len)
        _, _ -> False
      }
    }
  }
}

/// @patch("gleam/bit_array.starts_with")
pub fn starts_with(bits: BitArray, prefix: BitArray) -> Bool {
  let pref_len = mgp.bit_size(prefix)
  case pref_len > mgp.bit_size(bits) {
    True -> False
    False -> starts_with_loop(bits, prefix, 0, pref_len)
  }
}
