import gekko_stdlib/ffi/builtin as mbuiltin
import gekko_stdlib/ffi/prelude as mgp
import gekko_stdlib/ffi/utf8 as mutf8
import gekko_stdlib/graphemes
import gleam/list
import gleam/option.{None, Some}

/// @patch_type("gleam/string_tree.StringTree")
pub type StringTree =
  String

/// @patch("gleam/string_tree.do_to_graphemes")
pub fn do_to_graphemes(string: String) -> List(String) {
  graphemes.split(string)
}

/// @patch("gleam/string_tree.append_tree")
pub fn append_tree(tree: StringTree, suffix: StringTree) -> StringTree {
  from_string(to_string(tree) <> to_string(suffix))
}

/// @patch("gleam/string_tree.from_strings")
pub fn from_strings(strings: List(String)) -> StringTree {
  let buf = mbuiltin.new_string_builder(None)
  list.each(strings, fn(s) { mbuiltin.write_string(buf, s) })
  from_string(mbuiltin.string_builder_to_string(buf))
}

/// @patch("gleam/string_tree.concat")
pub fn concat(trees: List(StringTree)) -> StringTree {
  let buf = mbuiltin.new_string_builder(None)
  list.each(trees, fn(t) { mbuiltin.write_string(buf, to_string(t)) })
  from_string(mbuiltin.string_builder_to_string(buf))
}

/// @patch("gleam/string_tree.from_string")
pub fn from_string(string: String) -> StringTree {
  string
}

/// @patch("gleam/string_tree.to_string")
pub fn to_string(tree: StringTree) -> String {
  tree
}

/// @patch("gleam/string_tree.byte_size")
pub fn byte_size(tree: StringTree) -> Int {
  mgp.byte_size(mutf8.encode(to_string(tree), None))
}

/// @patch("gleam/string_tree.lowercase")
pub fn lowercase(tree: StringTree) -> StringTree {
  from_string(mbuiltin.string_to_lower(to_string(tree)))
}

/// @patch("gleam/string_tree.uppercase")
pub fn uppercase(tree: StringTree) -> StringTree {
  from_string(mbuiltin.string_to_upper(to_string(tree)))
}

fn split_loop(
  s: String,
  pattern: String,
  acc: List(StringTree),
) -> List(StringTree) {
  case mbuiltin.string_split_once(s, pattern) {
    Some(#(before, after)) ->
      split_loop(after, pattern, [from_string(before), ..acc])
    None -> list.reverse([from_string(s), ..acc])
  }
}

/// @patch("gleam/string_tree.split")
pub fn split(tree: StringTree, pattern: String) -> List(StringTree) {
  let s = to_string(tree)
  case pattern {
    "" -> list.map(graphemes.split(s), from_string)
    _ -> split_loop(s, pattern, [])
  }
}

/// @patch("gleam/string_tree.replace")
pub fn replace(
  tree: StringTree,
  pattern: String,
  substitute: String,
) -> StringTree {
  from_string(mbuiltin.string_replace_all(to_string(tree), pattern, substitute))
}
