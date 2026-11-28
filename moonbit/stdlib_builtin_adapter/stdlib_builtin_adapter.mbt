///|
fn __to_int32(x : Int64) -> Int {
  if x < -2147483648L || x > 2147483647L {
    abort("Int64 out of Int32 range")
  }
  x.to_int()
}

///|
pub fn[T : Show] eprintln(x : T) -> Unit {
  @prelude.eprintln(x)
}

///|
pub fn[T : Show] println(x : T) -> Unit {
  @prelude.println(x)
}

///|
pub fn char_to_int(self_ : Char) -> Int64 {
  (Char::to_int(self_)).to_int64()
}

///|
pub fn int32_to_char(self_ : Int64) -> Char? {
  Int32::to_char(__to_int32(self_))
}

///|
pub fn int64_land(self_ : Int64, arg1 : Int64) -> Int64 {
  Int64::land(self_, arg1)
}

///|
pub fn int64_lnot(self_ : Int64) -> Int64 {
  Int64::lnot(self_)
}

///|
pub fn int64_lor(self_ : Int64, arg1 : Int64) -> Int64 {
  Int64::lor(self_, arg1)
}

///|
pub fn int64_lxor(self_ : Int64, arg1 : Int64) -> Int64 {
  Int64::lxor(self_, arg1)
}

///|
pub fn int64_to_double(self_ : Int64) -> Double {
  Int64::to_double(self_)
}

///|
pub fn int64_to_string(self_ : Int64, radix : Int64?) -> StringView {
  (Int64::to_string(self_, radix?=(radix).map(fn(x0) { __to_int32(x0) }))).to_string_view()
}

///|
pub fn double_to_int64(self_ : Double) -> Int64 {
  Double::to_int64(self_)
}

///|
pub fn double_to_string(self_ : Double) -> StringView {
  (Double::to_string(self_)).to_string_view()
}

///|
pub fn string_at(self_ : StringView, arg1 : Int64) -> Int64 {
  (StringView::at(self_, __to_int32(arg1))).to_int64()
}

///|
pub fn string_contains(self_ : StringView, arg1 : StringView) -> Bool {
  StringView::contains(self_, arg1)
}

///|
pub fn string_find(self_ : StringView, arg1 : StringView) -> Int64? {
  (StringView::find(self_, arg1)).map(fn(x0) { (x0).to_int64() })
}

///|
pub fn string_from_array(arg0 : @gprelude.GList[Char]) -> StringView {
  StringView::from_array((arg0).to_array()[:])
}

///|
pub fn string_has_prefix(self_ : StringView, arg1 : StringView) -> Bool {
  StringView::has_prefix(self_, arg1)
}

///|
pub fn string_has_suffix(self_ : StringView, arg1 : StringView) -> Bool {
  StringView::has_suffix(self_, arg1)
}

///|
pub fn string_length(self_ : StringView) -> Int64 {
  (StringView::length(self_)).to_int64()
}

///|
pub fn string_replace_all(self_ : StringView, old : StringView, new : StringView) -> StringView {
  StringView::replace_all(self_, old=old, new=new)
}

///|
pub fn string_split_once(self_ : StringView, arg1 : StringView) -> (StringView, StringView)? {
  StringView::split_once(self_, arg1)
}

///|
pub fn string_to_array(self_ : StringView) -> @gprelude.GList[Char] {
  @gprelude.GList::from_array((StringView::to_array(self_))[:])
}

///|
pub fn string_to_lower(self_ : StringView) -> StringView {
  StringView::to_lower(self_)
}

///|
pub fn string_to_string(self_ : StringView) -> StringView {
  StringView::to_string_view(self_)
}

///|
pub fn string_to_upper(self_ : StringView) -> StringView {
  StringView::to_upper(self_)
}

///|
pub fn string_trim_end(self_ : StringView, chars : StringView?) -> StringView {
  StringView::trim_end(self_, chars?=chars)
}

///|
pub fn string_trim_start(self_ : StringView, chars : StringView?) -> StringView {
  StringView::trim_start(self_, chars?=chars)
}

///|
pub fn unsafe_substring(self_ : StringView, start : Int64, end : Int64) -> StringView {
  StringView::unsafe_view(self_, start=__to_int32(start), end=__to_int32(end))
}

///|
pub fn[K : Hash + Eq, V] new_map(arg0 : @gprelude.GList[(K, V)], capacity : Int64?) -> Map[K, V] {
  Map((arg0).to_array().map(fn(x0) { x0 })[:], capacity?=(capacity).map(fn(x0) { __to_int32(x0) }))
}

///|
pub fn[K : Hash + Eq, V] map_get(self_ : Map[K, V], arg1 : K) -> V? {
  Map::get(self_, arg1)
}

///|
pub fn[K, V] map_to_array(self_ : Map[K, V]) -> @gprelude.GList[(K, V)] {
  @gprelude.GList::from_array((Map::to_array(self_)).map(fn(x0) { x0 })[:])
}

///|
pub fn new_string_builder(capacity : Int64?) -> StringBuilder {
  StringBuilder(capacity?=(capacity).map(fn(x0) { __to_int32(x0) }))
}

///|
pub fn string_builder_to_string(self_ : StringBuilder) -> StringView {
  (StringBuilder::to_string(self_)).to_string_view()
}

///|
pub fn write_char(self_ : StringBuilder, arg1 : Char) -> Unit {
  StringBuilder::write_char(self_, arg1)
}

///|
pub fn write_string(self_ : StringBuilder, arg1 : StringView) -> Unit {
  StringBuilder::write_view(self_, arg1)
}
