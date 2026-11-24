///|
let float_rng : @random.Rand = @random.Rand::chacha8()

///|
pub fn int_parse(s : String) -> Result[Int64, Unit] {
  int_base_parse(s, 10L)
}

///|
pub fn int_base_parse(s : String, base : Int64) -> Result[Int64, Unit] {
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
pub fn int_to_string(x : Int64) -> String {
  x.to_string()
}

///|
pub fn int_to_base_string(x : Int64, base : Int64) -> String {
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
pub fn int_to_float(x : Int64) -> Double {
  x.to_double()
}

///|
pub fn int_bitwise_and(x : Int64, y : Int64) -> Int64 {
  x & y
}

///|
pub fn int_bitwise_not(x : Int64) -> Int64 {
  x.lnot()
}

///|
pub fn int_bitwise_or(x : Int64, y : Int64) -> Int64 {
  x | y
}

///|
pub fn int_bitwise_exclusive_or(x : Int64, y : Int64) -> Int64 {
  x ^ y
}

///|
pub fn int_bitwise_shift_left(x : Int64, y : Int64) -> Int64 {
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
pub fn int_bitwise_shift_right(x : Int64, y : Int64) -> Int64 {
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

///|
pub fn float_parse(s : String) -> Result[Double, Unit] {
  if !(s.contains(".")) {
    return Err(())
  }
  try {
    Ok(@str.parse_double(s))
  } catch {
    _ => Err(())
  }
}

///|
pub fn float_to_string(x : Double) -> String {
  let raw = x.to_string().replace_all(old="+", new="").replace_all(old="E", new="e")
  if raw.contains(".") {
    raw
  } else {
    match raw.find("e") {
      Some(idx) =>
        raw.unsafe_substring(start=0, end=idx) +
        ".0" +
        raw.unsafe_substring(start=idx, end=raw.length())
      None =>
        if raw != "NaN" && raw != "Infinity" && raw != "-Infinity" {
          raw + ".0"
        } else {
          raw
        }
    }
  }
}

///|
pub fn float_ceiling(x : Double) -> Double {
  @dbl.ceil(x)
}

///|
pub fn float_floor(x : Double) -> Double {
  @dbl.floor(x)
}

///|
pub fn float_round(x : Double) -> Int64 {
  let t = @dbl.trunc(x)
  let frac = x - t
  if frac >= 0.5 {
    (t + 1.0).to_int64()
  } else if frac <= -0.5 {
    (t - 1.0).to_int64()
  } else {
    t.to_int64()
  }
}

///|
pub fn float_truncate(x : Double) -> Int64 {
  @dbl.trunc(x).to_int64()
}

///|
pub fn float_power(base : Double, exponent : Double) -> Double {
  @math.pow(base, exponent)
}

///|
pub fn float_random() -> Double {
  float_rng.double(min=0.0, max=1.0)
}

///|
pub fn float_log(x : Double) -> Double {
  @math.ln(x)
}

///|
pub fn float_exponential(x : Double) -> Double {
  @math.exp(x)
}
