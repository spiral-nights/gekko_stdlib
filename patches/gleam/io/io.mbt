///|
#gekko.patch
pub fn print(s : String) -> Unit {
  println(s)
}

///|
#gekko.patch
pub fn print_error(s : String) -> Unit {
  eprintln(s)
}

///|
#gekko.patch("println")
pub fn println_(s : String) -> Unit {
  println(s)
}

///|
#gekko.patch
pub fn println_error(s : String) -> Unit {
  eprintln(s)
}
