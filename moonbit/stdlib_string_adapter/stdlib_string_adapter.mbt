///|
pub fn parse_double(x : StringView) -> Result[Double, StringView] {
  try {
    let __res = @moonbitlang_core_string.parse_double(x)
    Ok(__res)
  } catch {
    __err => Err((Error::to_string(__err)).to_string_view())
  }
}
