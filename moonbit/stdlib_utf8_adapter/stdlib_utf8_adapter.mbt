///|
pub fn decode(arg0 : @gprelude.BitArray, ignore_bom : Bool?) -> Result[StringView, StringView] {
  try {
    let __res = @moonbitlang_core_encoding_utf8.decode((arg0).data[:], ignore_bom?=ignore_bom)
    Ok((__res).to_string_view())
  } catch {
    __err => Err((Error::to_string(__err)).to_string_view())
  }
}

///|
pub fn encode(arg0 : StringView, bom : Bool?) -> @gprelude.BitArray {
  @gprelude.BitArray::from_bytes(@moonbitlang_core_encoding_utf8.encode(arg0, bom?=bom))
}
