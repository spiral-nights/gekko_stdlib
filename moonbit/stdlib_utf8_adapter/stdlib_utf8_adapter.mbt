///|
pub fn decode(arg0 : @gprelude.BitArray, ignore_bom : Bool?) -> Result[String, String] {
  try {
    let __res = @moonbitlang_core_encoding_utf8.decode((arg0).data[:], ignore_bom?=ignore_bom)
    Ok(__res)
  } catch {
    __err => Err(Error::to_string(__err))
  }
}

///|
pub fn encode(arg0 : String, bom : Bool?) -> @gprelude.BitArray {
  @gprelude.BitArray::from_bytes(@moonbitlang_core_encoding_utf8.encode((arg0).to_string_view(), bom?=bom))
}
