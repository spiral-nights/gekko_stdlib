///|
#gekko.patch
pub fn parse(s : String) -> Result[Int64, Unit] {
  do_base_parse(s, 10L)
}

///|
#gekko.patch
fn do_base_parse(s : String, base : Int64) -> Result[Int64, Unit] {
  if base < 2L || base > 36L || s == "" {
    return Err(())
  }
  let chars = s.iter().collect()
  let mut i = 0
  let mut sign = 1L
  if chars[0] == '-' {
    sign = -1L
    i = 1
  } else if chars[0] == '+' {
    i = 1
  }
  if i >= chars.length() {
    return Err(())
  }
  let mut acc = 0L
  while i < chars.length() {
    let c = chars[i]
    let digit = if c >= '0' && c <= '9' {
      (c.to_int() - '0'.to_int()).to_int64()
    } else if c >= 'a' && c <= 'z' {
      (c.to_int() - 'a'.to_int() + 10).to_int64()
    } else if c >= 'A' && c <= 'Z' {
      (c.to_int() - 'A'.to_int() + 10).to_int64()
    } else {
      -1L
    }
    if digit < 0L || digit >= base {
      return Err(())
    }
    acc = acc * base + sign * digit
    i = i + 1
  }
  Ok(acc)
}

///|
#gekko.patch
pub fn to_string(x : Int64) -> String {
  x.to_string()
}

///|
#gekko.patch
fn do_to_base_string(x : Int64, base : Int64) -> String {
  if base < 2L || base > 36L {
    return ""
  }
  if x == 0L {
    return "0"
  }
  let digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let neg = x < 0L
  let mut n = x
  let rev : Array[Char] = []
  while n != 0L {
    let rem = n % base
    let d = (if rem < 0L { -rem } else { rem }).to_int()
    rev.push(digits[d].to_int().unsafe_to_char())
    n = n / base
  }
  let buf = StringBuilder()
  if neg {
    buf.write_char('-')
  }
  let mut i = rev.length() - 1
  while i >= 0 {
    buf.write_char(rev[i])
    i = i - 1
  }
  buf.to_string()
}

///|
#gekko.patch
pub fn to_float(x : Int64) -> Double {
  x.to_double()
}

///|
#gekko.patch
pub fn bitwise_and(x : Int64, y : Int64) -> Int64 {
  x & y
}

///|
#gekko.patch
pub fn bitwise_not(x : Int64) -> Int64 {
  x.lnot()
}

///|
#gekko.patch
pub fn bitwise_or(x : Int64, y : Int64) -> Int64 {
  x | y
}

///|
#gekko.patch
pub fn bitwise_exclusive_or(x : Int64, y : Int64) -> Int64 {
  x ^ y
}

///|
#gekko.patch
pub fn bitwise_shift_left(x : Int64, y : Int64) -> Int64 {
  if y < 0L {
    if y <= -64L {
      if x < 0L { -1L } else { 0L }
    } else {
      x >> (-y).to_int()
    }
  } else if y >= 64L {
    0L
  } else {
    x << y.to_int()
  }
}

///|
#gekko.patch
pub fn bitwise_shift_right(x : Int64, y : Int64) -> Int64 {
  if y < 0L {
    if y <= -64L {
      0L
    } else {
      x << (-y).to_int()
    }
  } else if y >= 64L {
    if x < 0L { -1L } else { 0L }
  } else {
    x >> y.to_int()
  }
}

