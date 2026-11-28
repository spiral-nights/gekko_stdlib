import gekko_stdlib/ffi/builtin as mbuiltin
import gekko_stdlib/ffi/prelude as mgp
import gekko_stdlib/ffi/utf8 as mutf8
import gekko_stdlib/graphemes
import gleam/list
import gleam/option.{None, Some}
import gleam/string_tree.{type StringTree}

const gleam_whitespace =
  " \t\n\r\u{000B}\u{000C}\u{0085}\u{200E}\u{200F}\u{2028}\u{2029}"

/// @patch("gleam/string.length")
pub fn length(s: String) -> Int {
  graphemes.count(s)
}

/// @patch("gleam/string.lowercase")
pub fn lowercase(s: String) -> String {
  mbuiltin.string_to_lower(s)
}

/// @patch("gleam/string.uppercase")
pub fn uppercase(s: String) -> String {
  mbuiltin.string_to_upper(s)
}

fn codepoints_lt(xs: List(UtfCodepoint), ys: List(UtfCodepoint)) -> Bool {
  case xs, ys {
    [a, ..rest_a], [b, ..rest_b] -> {
      let ca = mbuiltin.char_to_int(a)
      let cb = mbuiltin.char_to_int(b)
      case ca == cb {
        True -> codepoints_lt(rest_a, rest_b)
        False -> ca < cb
      }
    }
    [], [_, ..] -> True
    _, _ -> False
  }
}

/// @patch("gleam/string.less_than")
pub fn less_than(a: String, b: String) -> Bool {
  codepoints_lt(mbuiltin.string_to_array(a), mbuiltin.string_to_array(b))
}

/// @patch("gleam/string.grapheme_slice")
pub fn grapheme_slice(from: String, index: Int, length: Int) -> String {
  case length <= 0 {
    True -> ""
    False -> {
      let clusters = graphemes.split(from)
      let total = list.length(clusters)
      let start = case index < 0 {
        True -> total + index
        False -> index
      }
      case start < 0 || start >= total {
        True -> ""
        False ->
          clusters
          |> list.drop(start)
          |> list.take(length)
          |> fn(sliced) {
            let buf = mbuiltin.new_string_builder(None)
            list.each(sliced, fn(g) { mbuiltin.write_string(buf, g) })
            mbuiltin.string_builder_to_string(buf)
          }
      }
    }
  }
}

/// @patch("gleam/string.unsafe_byte_slice")
pub fn unsafe_byte_slice(s: String, index: Int, length: Int) -> String {
  case length <= 0 {
    True -> ""
    False -> {
      let encoded = mutf8.encode(s, None)
      let total = mgp.byte_size(encoded)
      let start = case index < 0 {
        True -> total + index
        False -> index
      }
      case start < 0 || start >= total {
        True -> ""
        False -> {
          let avail = total - start
          let count = case length > avail {
            True -> avail
            False -> length
          }
          case mgp.bit_array_read_bits(encoded, start * 8, count * 8) {
            Some(sub) ->
              case mutf8.decode(sub, None) {
                Ok(decoded) -> decoded
                Error(_) -> ""
              }
            None -> ""
          }
        }
      }
    }
  }
}

/// @patch("gleam/string.crop")
pub fn crop(from: String, before: String) -> String {
  case mbuiltin.string_find(from, before) {
    Some(idx) ->
      mbuiltin.unsafe_substring(from, idx, mbuiltin.string_length(from))
    None -> from
  }
}

/// @patch("gleam/string.contains")
pub fn contains(haystack: String, needle: String) -> Bool {
  mbuiltin.string_contains(haystack, needle)
}

/// @patch("gleam/string.starts_with")
pub fn starts_with(s: String, prefix: String) -> Bool {
  mbuiltin.string_has_prefix(s, prefix)
}

/// @patch("gleam/string.ends_with")
pub fn ends_with(s: String, suffix: String) -> Bool {
  mbuiltin.string_has_suffix(s, suffix)
}

/// @patch("gleam/string.split_once")
pub fn split_once(s: String, on: String) -> Result(#(String, String), Nil) {
  case mbuiltin.string_split_once(s, on) {
    Some(pair) -> Ok(pair)
    None -> Error(Nil)
  }
}

/// @patch("gleam/string.trim")
pub fn trim(s: String) -> String {
  s
  |> trim_start
  |> trim_end
}

/// @patch("gleam/string.trim_start")
pub fn trim_start(s: String) -> String {
  mbuiltin.string_trim_start(s, Some(gleam_whitespace))
}

/// @patch("gleam/string.trim_end")
pub fn trim_end(s: String) -> String {
  mbuiltin.string_trim_end(s, Some(gleam_whitespace))
}

/// @patch("gleam/string.pop_grapheme")
pub fn pop_grapheme(s: String) -> Result(#(String, String), Nil) {
  graphemes.pop(s)
}

/// @patch("gleam/string.unsafe_int_to_utf_codepoint")
pub fn unsafe_int_to_utf_codepoint(a: Int) -> UtfCodepoint {
  case mbuiltin.int32_to_char(a) {
    Some(cp) -> cp
    None -> panic as "Invalid Unicode codepoint"
  }
}

/// @patch("gleam/string.to_utf_codepoints")
pub fn to_utf_codepoints(s: String) -> List(UtfCodepoint) {
  mbuiltin.string_to_array(s)
}

/// @patch("gleam/string.from_utf_codepoints")
pub fn from_utf_codepoints(cps: List(UtfCodepoint)) -> String {
  mbuiltin.string_from_array(cps)
}

/// @patch("gleam/string.utf_codepoint_to_int")
pub fn utf_codepoint_to_int(cp: UtfCodepoint) -> Int {
  mbuiltin.char_to_int(cp)
}

/// @patch("gleam/string.do_inspect")
pub fn do_inspect(term: anything) -> StringTree {
  string_tree.from_string(mgp.gleam_inspect(term))
}

/// @patch("gleam/string.byte_size")
pub fn byte_size(s: String) -> Int {
  mgp.byte_size(mutf8.encode(s, None))
}

/// @patch("gleam/string.remove_prefix")
pub fn remove_prefix(from: String, matching: String) -> String {
  case mbuiltin.string_has_prefix(from, matching) {
    True ->
      mbuiltin.unsafe_substring(
        from,
        mbuiltin.string_length(matching),
        mbuiltin.string_length(from),
      )
    False -> from
  }
}

/// @patch("gleam/string.remove_suffix")
pub fn remove_suffix(from: String, matching: String) -> String {
  case mbuiltin.string_has_suffix(from, matching) {
    True ->
      mbuiltin.unsafe_substring(
        from,
        0,
        mbuiltin.string_length(from) - mbuiltin.string_length(matching),
      )
    False -> from
  }
}
