import gekko_stdlib/ffi/builtin as mbuiltin
import gekko_stdlib/ffi/prelude as mgp
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{
  type DecodeError, type Lookup, DecodeError, Found, InvalidIndex, InvalidKey,
  Missing,
}
import gleam/int
import gleam/list
import gleam/option.{None, Some}

fn make_decode_error(expected: String, data: Dynamic) -> List(DecodeError) {
  [DecodeError(expected:, found: dynamic.classify(data), path: [])]
}

fn list_at_nonneg(xs: List(a), idx: Int) -> Result(a, Nil) {
  case xs, idx {
    [], _ -> Error(Nil)
    [x, ..], 0 -> Ok(x)
    [_, ..rest], n -> list_at_nonneg(rest, n - 1)
  }
}

/// @patch("gleam/dynamic/decode.lookup_field")
pub fn lookup_field(data: Dynamic, name: k) -> Lookup {
  let dk = mgp.to_dynamic(name)
  mgp.match_dynamic(
    data,
    fn() {
      mgp.match_dynamic(
        dk,
        fn() { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidIndex },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
      )
    },
    fn(_) {
      mgp.match_dynamic(
        dk,
        fn() { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidIndex },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
      )
    },
    fn(_) {
      mgp.match_dynamic(
        dk,
        fn() { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidIndex },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
      )
    },
    fn(_) {
      mgp.match_dynamic(
        dk,
        fn() { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidIndex },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
      )
    },
    fn(_) {
      mgp.match_dynamic(
        dk,
        fn() { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidIndex },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
      )
    },
    fn(_) {
      mgp.match_dynamic(
        dk,
        fn() { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidIndex },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
        fn(_) { InvalidKey },
      )
    },
    fn(xs) {
      mgp.match_dynamic(
        dk,
        fn() { Missing },
        fn(_) { Missing },
        fn(idx) {
          case idx < 0 {
            True -> Missing
            False ->
              case list_at_nonneg(xs, idx) {
                Ok(value) -> Found(value:)
                Error(_) -> Missing
              }
          }
        },
        fn(_) { Missing },
        fn(_) { Missing },
        fn(_) { Missing },
        fn(_) { Missing },
        fn(_) { Missing },
        fn(_) { Missing },
      )
    },
    fn(arr) {
      mgp.match_dynamic(
        dk,
        fn() { Missing },
        fn(_) { Missing },
        fn(idx) {
          case idx < 0 {
            True -> Missing
            False ->
              case list_at_nonneg(arr, idx) {
                Ok(value) -> Found(value:)
                Error(_) -> Missing
              }
          }
        },
        fn(_) { Missing },
        fn(_) { Missing },
        fn(_) { Missing },
        fn(_) { Missing },
        fn(_) { Missing },
        fn(_) { Missing },
      )
    },
    fn(m) {
      case mbuiltin.map_get(m, dk) {
        Some(value) -> Found(value:)
        None -> Missing
      }
    },
  )
}

/// @patch("gleam/dynamic/decode.key_to_string")
pub fn key_to_string(key: anything) -> String {
  let dk = mgp.to_dynamic(key)
  mgp.match_dynamic(
    dk,
    fn() { "<" <> dynamic.classify(dk) <> ">" },
    fn(_) { "<" <> dynamic.classify(dk) <> ">" },
    fn(i) { mbuiltin.int64_to_string(i, None) },
    fn(f) { mbuiltin.double_to_string(f) },
    fn(s) { s },
    fn(_) { "<" <> dynamic.classify(dk) <> ">" },
    fn(_) { "<" <> dynamic.classify(dk) <> ">" },
    fn(_) { "<" <> dynamic.classify(dk) <> ">" },
    fn(_) { "<" <> dynamic.classify(dk) <> ">" },
  )
}

/// @patch("gleam/dynamic/decode.decode_string")
pub fn decode_string(data: Dynamic) -> #(String, List(DecodeError)) {
  mgp.match_dynamic(
    data,
    fn() { #("", make_decode_error("String", data)) },
    fn(_) { #("", make_decode_error("String", data)) },
    fn(_) { #("", make_decode_error("String", data)) },
    fn(_) { #("", make_decode_error("String", data)) },
    fn(s) { #(s, []) },
    fn(_) { #("", make_decode_error("String", data)) },
    fn(_) { #("", make_decode_error("String", data)) },
    fn(_) { #("", make_decode_error("String", data)) },
    fn(_) { #("", make_decode_error("String", data)) },
  )
}

/// @patch("gleam/dynamic/decode.decode_bool")
pub fn decode_bool(data: Dynamic) -> #(Bool, List(DecodeError)) {
  mgp.match_dynamic(
    data,
    fn() { #(False, make_decode_error("Bool", data)) },
    fn(b) { #(b, []) },
    fn(_) { #(False, make_decode_error("Bool", data)) },
    fn(_) { #(False, make_decode_error("Bool", data)) },
    fn(_) { #(False, make_decode_error("Bool", data)) },
    fn(_) { #(False, make_decode_error("Bool", data)) },
    fn(_) { #(False, make_decode_error("Bool", data)) },
    fn(_) { #(False, make_decode_error("Bool", data)) },
    fn(_) { #(False, make_decode_error("Bool", data)) },
  )
}

/// @patch("gleam/dynamic/decode.decode_int")
pub fn decode_int(data: Dynamic) -> #(Int, List(DecodeError)) {
  mgp.match_dynamic(
    data,
    fn() { #(0, make_decode_error("Int", data)) },
    fn(_) { #(0, make_decode_error("Int", data)) },
    fn(i) { #(i, []) },
    fn(_) { #(0, make_decode_error("Int", data)) },
    fn(_) { #(0, make_decode_error("Int", data)) },
    fn(_) { #(0, make_decode_error("Int", data)) },
    fn(_) { #(0, make_decode_error("Int", data)) },
    fn(_) { #(0, make_decode_error("Int", data)) },
    fn(_) { #(0, make_decode_error("Int", data)) },
  )
}

/// @patch("gleam/dynamic/decode.decode_float")
pub fn decode_float(data: Dynamic) -> #(Float, List(DecodeError)) {
  mgp.match_dynamic(
    data,
    fn() { #(0.0, make_decode_error("Float", data)) },
    fn(_) { #(0.0, make_decode_error("Float", data)) },
    fn(_) { #(0.0, make_decode_error("Float", data)) },
    fn(f) { #(f, []) },
    fn(_) { #(0.0, make_decode_error("Float", data)) },
    fn(_) { #(0.0, make_decode_error("Float", data)) },
    fn(_) { #(0.0, make_decode_error("Float", data)) },
    fn(_) { #(0.0, make_decode_error("Float", data)) },
    fn(_) { #(0.0, make_decode_error("Float", data)) },
  )
}

/// @patch("gleam/dynamic/decode.decode_bit_array")
pub fn decode_bit_array(data: Dynamic) -> #(BitArray, List(DecodeError)) {
  mgp.match_dynamic(
    data,
    fn() { #(<<>>, make_decode_error("BitArray", data)) },
    fn(_) { #(<<>>, make_decode_error("BitArray", data)) },
    fn(_) { #(<<>>, make_decode_error("BitArray", data)) },
    fn(_) { #(<<>>, make_decode_error("BitArray", data)) },
    fn(_) { #(<<>>, make_decode_error("BitArray", data)) },
    fn(ba) { #(ba, []) },
    fn(_) { #(<<>>, make_decode_error("BitArray", data)) },
    fn(_) { #(<<>>, make_decode_error("BitArray", data)) },
    fn(_) { #(<<>>, make_decode_error("BitArray", data)) },
  )
}

fn decode_list_loop(
  elements: List(Dynamic),
  idx: Int,
  acc: List(a),
  inner: fn(Dynamic) -> #(a, List(DecodeError)),
  prefix_errors: fn(String, List(DecodeError)) -> List(DecodeError),
) -> #(List(a), List(DecodeError)) {
  case elements {
    [] -> #(list.reverse(acc), [])
    [elem, ..rest] ->
      case inner(elem) {
        #(decoded, []) ->
          decode_list_loop(
            rest,
            idx + 1,
            [decoded, ..acc],
            inner,
            prefix_errors,
          )
        #(_, errs) -> #([], prefix_errors(int.to_string(idx), errs))
      }
  }
}

/// @patch("gleam/dynamic/decode.decode_list")
pub fn decode_list(
  data: Dynamic,
  inner: fn(Dynamic) -> #(a, List(DecodeError)),
  prefix_errors: fn(String, List(DecodeError)) -> List(DecodeError),
) -> #(List(a), List(DecodeError)) {
  let els_res =
    mgp.match_dynamic(
      data,
      fn() { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(xs) { Ok(xs) },
      fn(arr) { Ok(arr) },
      fn(_) { Error(Nil) },
    )
  case els_res {
    Error(_) -> #([], make_decode_error("List", data))
    Ok(elements) -> decode_list_loop(elements, 0, [], inner, prefix_errors)
  }
}

fn decode_dict_loop(
  entries: List(#(Dynamic, Dynamic)),
  acc: Dict(k, v),
  decode_entry: fn(Dict(k, v), Dynamic, Dynamic) ->
    #(Dict(k, v), List(DecodeError)),
) -> #(Dict(k, v), List(DecodeError)) {
  case entries {
    [] -> #(acc, [])
    [#(k, v), ..rest] ->
      case decode_entry(acc, k, v) {
        #(next_acc, []) -> decode_dict_loop(rest, next_acc, decode_entry)
        err_res -> err_res
      }
  }
}

/// @patch("gleam/dynamic/decode.decode_dict")
pub fn decode_dict(
  data: Dynamic,
  decode_entry: fn(Dict(k, v), Dynamic, Dynamic) ->
    #(Dict(k, v), List(DecodeError)),
) -> #(Dict(k, v), List(DecodeError)) {
  let entries_res =
    mgp.match_dynamic(
      data,
      fn() { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(_) { Error(Nil) },
      fn(m) { Ok(mbuiltin.map_to_array(m)) },
    )
  case entries_res {
    Error(_) -> #(dict.new(), make_decode_error("Dict", data))
    Ok(entries) -> decode_dict_loop(entries, dict.new(), decode_entry)
  }
}

/// @patch("gleam/dynamic/decode.is_null")
pub fn is_null(a: Dynamic) -> Bool {
  mgp.match_dynamic(
    a,
    fn() { True },
    fn(_) { False },
    fn(_) { False },
    fn(_) { False },
    fn(_) { False },
    fn(_) { False },
    fn(_) { False },
    fn(_) { False },
    fn(_) { False },
  )
}
