///|
pub fn parse_double(x : String) -> Result[Double, String] {
  try {
    let __res = @moonbitlang_core_string.parse_double((x).to_string_view())
    Ok(__res)
  } catch {
    __err => Err(Error::to_string(__err))
  }
}
