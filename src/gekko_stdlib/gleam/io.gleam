import gekko_stdlib/ffi/builtin as mbuiltin

/// @patch("gleam/io.print")
pub fn print(string: String) -> Nil {
  mbuiltin.println(string)
}

/// @patch("gleam/io.print_error")
pub fn print_error(string: String) -> Nil {
  mbuiltin.eprintln(string)
}

/// @patch("gleam/io.println")
pub fn println(string: String) -> Nil {
  mbuiltin.println(string)
}

/// @patch("gleam/io.println_error")
pub fn println_error(string: String) -> Nil {
  mbuiltin.eprintln(string)
}
