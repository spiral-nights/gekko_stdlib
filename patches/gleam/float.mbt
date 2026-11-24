///|
fn do_to_float(x : Int64) -> Double {
  x.to_double()
}

///|
let float_rng : @random.Rand = @random.Rand::chacha8()

///|
pub fn parse(s : String) -> Result[Double, Unit] {
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
pub fn to_string(x : Double) -> String {
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
pub fn ceiling(x : Double) -> Double {
  @dbl.ceil(x)
}

///|
pub fn floor(x : Double) -> Double {
  @dbl.floor(x)
}

///|
pub fn round(x : Double) -> Int64 {
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
pub fn truncate(x : Double) -> Int64 {
  @dbl.trunc(x).to_int64()
}

///|
fn do_power(base : Double, exponent : Double) -> Double {
  @math.pow(base, exponent)
}

///|
pub fn random() -> Double {
  float_rng.double(min=0.0, max=1.0)
}

///|
fn do_log(x : Double) -> Double {
  @math.ln(x)
}

///|
pub fn exponential(x : Double) -> Double {
  @math.exp(x)
}
