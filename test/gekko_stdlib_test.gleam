import gleam/bit_array
import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/option
import gleam/string
import gleam/string_tree
import gleam/uri
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn int_float_string_smoke_test() {
  assert int.parse("42") == Ok(42)
  assert int.to_string(42) == "42"
  assert float.parse("3.5") == Ok(3.5)
  assert string.uppercase("gekko") == "GEKKO"
  assert string_tree.from_strings(["a", "b"]) |> string_tree.to_string == "ab"
}

pub fn dict_option_bit_array_smoke_test() {
  let d = dict.from_list([#("k", 7)])
  assert dict.get(d, "k") == Ok(7)
  assert option.unwrap(option.Some(10), 0) == 10
  assert bit_array.from_string("hi") |> bit_array.to_string == Ok("hi")
}

pub fn decode_and_uri_smoke_test() {
  let raw = dynamic.list([dynamic.int(1), dynamic.int(2), dynamic.int(3)])
  assert decode.run(raw, decode.list(decode.int)) == Ok([1, 2, 3])

  let bad = dynamic.list([dynamic.int(1), dynamic.string("nope")])
  let assert Error([decode.DecodeError(expected: "Int", path: ["1"], ..)]) =
    decode.run(bad, decode.list(decode.int))

  let assert Ok(parsed) = uri.parse("https://example.com/a?x=1")
  assert parsed.host == option.Some("example.com")
}
