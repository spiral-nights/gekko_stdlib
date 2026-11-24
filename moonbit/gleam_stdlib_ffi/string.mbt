///|
#derive(Eq, Debug, Hash)
pub(all) struct StringTree {
  text : String
}

///|
pub impl @gprelude.GleamInspect for StringTree with gleam_inspect(self) {
  @gprelude.GleamInspect::gleam_inspect(self.text)
}

///|
fn is_gcb_hangul_l(cp : Int) -> Bool {
  (cp >= 0x1100 && cp <= 0x115F) || (cp >= 0xA960 && cp <= 0xA97C)
}

///|
fn is_gcb_hangul_v(cp : Int) -> Bool {
  (cp >= 0x1160 && cp <= 0x11A7) || (cp >= 0xD7B0 && cp <= 0xD7C6)
}

///|
fn is_gcb_hangul_t(cp : Int) -> Bool {
  (cp >= 0x11A8 && cp <= 0x11FF) || (cp >= 0xD7CB && cp <= 0xD7FB)
}

///|
fn is_gcb_hangul_lv(cp : Int) -> Bool {
  cp >= 0xAC00 && cp <= 0xD7A3 && (cp - 0xAC00) % 28 == 0
}

///|
fn is_gcb_hangul_lvt(cp : Int) -> Bool {
  cp >= 0xAC00 && cp <= 0xD7A3 && (cp - 0xAC00) % 28 != 0
}

///|
fn is_gcb_control(cp : Int) -> Bool {
  (cp >= 0x0000 && cp <= 0x001F && cp != 0x000A && cp != 0x000D) ||
  (cp >= 0x007F && cp <= 0x009F) ||
  cp == 0x00AD ||
  cp == 0x061C ||
  cp == 0x200B ||
  (cp >= 0x200E && cp <= 0x200F) ||
  (cp >= 0x2028 && cp <= 0x202E) ||
  (cp >= 0x2060 && cp <= 0x206F) ||
  cp == 0xFEFF ||
  (cp >= 0xFFF0 && cp <= 0xFFFB)
}

///|
fn is_gcb_prepend(cp : Int) -> Bool {
  (cp >= 0x0600 && cp <= 0x0605) ||
  cp == 0x06DD ||
  cp == 0x070F ||
  (cp >= 0x0890 && cp <= 0x0891) ||
  cp == 0x08E2 ||
  cp == 0x0D4E ||
  cp == 0x110BD ||
  cp == 0x110CD ||
  (cp >= 0x111C2 && cp <= 0x111C3)
}

///|
fn is_gcb_extend(cp : Int) -> Bool {
  (cp >= 0x0300 && cp <= 0x036F) ||
  (cp >= 0x0483 && cp <= 0x0489) ||
  (cp >= 0x0591 && cp <= 0x05BD) ||
  cp == 0x05BF ||
  (cp >= 0x05C1 && cp <= 0x05C2) ||
  (cp >= 0x05C4 && cp <= 0x05C5) ||
  cp == 0x05C7 ||
  (cp >= 0x0610 && cp <= 0x061A) ||
  (cp >= 0x064B && cp <= 0x065F) ||
  cp == 0x0670 ||
  (cp >= 0x06D6 && cp <= 0x06DC) ||
  (cp >= 0x06DF && cp <= 0x06E4) ||
  (cp >= 0x06E7 && cp <= 0x06E8) ||
  (cp >= 0x06EA && cp <= 0x06ED) ||
  cp == 0x0711 ||
  (cp >= 0x0730 && cp <= 0x074A) ||
  (cp >= 0x07A6 && cp <= 0x07B0) ||
  (cp >= 0x07EB && cp <= 0x07F3) ||
  (cp >= 0x0816 && cp <= 0x0819) ||
  (cp >= 0x081B && cp <= 0x0823) ||
  (cp >= 0x0825 && cp <= 0x0827) ||
  (cp >= 0x0829 && cp <= 0x082D) ||
  (cp >= 0x08D3 && cp <= 0x08E1) ||
  (cp >= 0x08E3 && cp <= 0x0902) ||
  cp == 0x093A ||
  cp == 0x093C ||
  (cp >= 0x0941 && cp <= 0x0948) ||
  cp == 0x094D ||
  (cp >= 0x0951 && cp <= 0x0957) ||
  (cp >= 0x0962 && cp <= 0x0963) ||
  cp == 0x0981 ||
  cp == 0x09BC ||
  cp == 0x09BE ||
  (cp >= 0x09C1 && cp <= 0x09C4) ||
  cp == 0x09CD ||
  cp == 0x09D7 ||
  (cp >= 0x09E2 && cp <= 0x09E3) ||
  (cp >= 0x0E31 && cp <= 0x0E3A && cp != 0x0E32 && cp != 0x0E33) ||
  (cp >= 0x0E47 && cp <= 0x0E4E) ||
  cp == 0x0EB1 ||
  (cp >= 0x0EB4 && cp <= 0x0EBC) ||
  (cp >= 0x0EC8 && cp <= 0x0ECD) ||
  (cp >= 0x0F71 && cp <= 0x0F7E) ||
  (cp >= 0x0F80 && cp <= 0x0F84) ||
  (cp >= 0x0F86 && cp <= 0x0F87) ||
  (cp >= 0x0F8D && cp <= 0x0FBC) ||
  (cp >= 0x102D && cp <= 0x1030) ||
  (cp >= 0x1032 && cp <= 0x1037) ||
  (cp >= 0x1039 && cp <= 0x103A) ||
  (cp >= 0x1AB0 && cp <= 0x1ACE) ||
  (cp >= 0x1DC0 && cp <= 0x1DFF) ||
  cp == 0x200C ||
  (cp >= 0x20D0 && cp <= 0x20F0) ||
  (cp >= 0x2DE0 && cp <= 0x2DFF) ||
  (cp >= 0x302A && cp <= 0x302F) ||
  (cp >= 0x3099 && cp <= 0x309A) ||
  (cp >= 0xA674 && cp <= 0xA67D) ||
  (cp >= 0xFE00 && cp <= 0xFE0F) ||
  (cp >= 0xFE20 && cp <= 0xFE2F) ||
  (cp >= 0xFF9E && cp <= 0xFF9F) ||
  (cp >= 0x1F3FB && cp <= 0x1F3FF) ||
  (cp >= 0xE0020 && cp <= 0xE007F) ||
  (cp >= 0xE0100 && cp <= 0xE01EF)
}

///|
fn is_gcb_spacing_mark(cp : Int) -> Bool {
  cp == 0x0903 ||
  cp == 0x093B ||
  (cp >= 0x093E && cp <= 0x0940) ||
  (cp >= 0x0949 && cp <= 0x094C) ||
  (cp >= 0x094E && cp <= 0x094F) ||
  (cp >= 0x0982 && cp <= 0x0983) ||
  (cp >= 0x09BF && cp <= 0x09C0) ||
  (cp >= 0x09C7 && cp <= 0x09C8) ||
  (cp >= 0x09CB && cp <= 0x09CC)
}

///|
fn is_gcb_ri(cp : Int) -> Bool {
  cp >= 0x1F1E6 && cp <= 0x1F1FF
}

///|
fn is_gcb_ext_pict(cp : Int) -> Bool {
  cp == 0x00A9 ||
  cp == 0x00AE ||
  cp == 0x203C ||
  cp == 0x2049 ||
  cp == 0x2122 ||
  cp == 0x2139 ||
  (cp >= 0x2194 && cp <= 0x2199) ||
  (cp >= 0x21A9 && cp <= 0x21AA) ||
  (cp >= 0x231A && cp <= 0x231B) ||
  cp == 0x2328 ||
  cp == 0x23CF ||
  (cp >= 0x23E9 && cp <= 0x23F3) ||
  (cp >= 0x23F8 && cp <= 0x23FA) ||
  cp == 0x24C2 ||
  (cp >= 0x25AA && cp <= 0x25AB) ||
  cp == 0x25B6 ||
  cp == 0x25C0 ||
  (cp >= 0x25FB && cp <= 0x25FE) ||
  (cp >= 0x2600 && cp <= 0x27BF) ||
  (cp >= 0x2934 && cp <= 0x2935) ||
  (cp >= 0x2B05 && cp <= 0x2B07) ||
  (cp >= 0x2B1B && cp <= 0x2B1C) ||
  cp == 0x2B50 ||
  cp == 0x2B55 ||
  cp == 0x3030 ||
  cp == 0x303D ||
  cp == 0x3297 ||
  cp == 0x3299 ||
  (cp >= 0x1F000 && cp <= 0x1FAFF && !(is_gcb_ri(cp)) && !(cp >= 0x1F3FB && cp <= 0x1F3FF))
}

///|
fn next_grapheme_end(chars : Array[Char], start : Int) -> Int {
  let len = chars.length()
  if start >= len {
    return len
  }
  let mut i = start
  let first = chars[i].to_int()
  i = i + 1
  if i >= len {
    return i
  }
  // GB3: CR x LF
  if first == 0x0D && chars[i].to_int() == 0x0A {
    return i + 1
  }
  // GB4: (Control | CR | LF) ÷
  if first == 0x0D || first == 0x0A || is_gcb_control(first) {
    return i
  }
  let mut prev = first
  let mut ri_odd = is_gcb_ri(first)
  let mut ext_pict_zwj = is_gcb_ext_pict(first)
  let mut saw_zwj = first == 0x200D
  while i < len {
    let cur = chars[i].to_int()
    // GB5: ÷ (Control | CR | LF)
    if cur == 0x0D || cur == 0x0A || is_gcb_control(cur) {
      break
    }
    // GB6/GB7/GB8: Hangul syllable composition
    if is_gcb_hangul_l(prev) &&
      (is_gcb_hangul_l(cur) ||
      is_gcb_hangul_v(cur) ||
      is_gcb_hangul_lv(cur) ||
      is_gcb_hangul_lvt(cur)) {
      prev = cur
      i = i + 1
      continue
    }
    if (is_gcb_hangul_lv(prev) || is_gcb_hangul_v(prev)) &&
      (is_gcb_hangul_v(cur) || is_gcb_hangul_t(cur)) {
      prev = cur
      i = i + 1
      continue
    }
    if (is_gcb_hangul_lvt(prev) || is_gcb_hangul_t(prev)) &&
      is_gcb_hangul_t(cur) {
      prev = cur
      i = i + 1
      continue
    }
    // GB9: × (Extend | ZWJ)
    if is_gcb_extend(cur) {
      prev = cur
      i = i + 1
      continue
    }
    if cur == 0x200D {
      saw_zwj = true
      prev = cur
      i = i + 1
      continue
    }
    // GB9a: × SpacingMark
    if is_gcb_spacing_mark(cur) {
      saw_zwj = false
      ext_pict_zwj = false
      prev = cur
      i = i + 1
      continue
    }
    // GB9b: Prepend ×
    if is_gcb_prepend(prev) {
      prev = cur
      ri_odd = is_gcb_ri(cur)
      ext_pict_zwj = is_gcb_ext_pict(cur)
      saw_zwj = false
      i = i + 1
      continue
    }
    // GB11: ExtPict Extend* ZWJ × ExtPict
    if ext_pict_zwj && saw_zwj && is_gcb_ext_pict(cur) {
      saw_zwj = false
      prev = cur
      i = i + 1
      continue
    }
    // GB12/GB13: RI × RI when odd count of preceding RIs
    if is_gcb_ri(cur) && ri_odd {
      ri_odd = false
      prev = cur
      i = i + 1
      continue
    }
    break
  }
  i
}

///|
fn split_graphemes(s : String) -> Array[String] {
  let chars = s.iter().collect()
  let len = chars.length()
  let out : Array[String] = []
  let mut i = 0
  while i < len {
    let end = next_grapheme_end(chars, i)
    let buf = StringBuilder()
    let mut j = i
    while j < end {
      buf.write_char(chars[j])
      j = j + 1
    }
    out.push(buf.to_string())
    i = end
  }
  out
}

///|
pub fn string_length(s : String) -> Int64 {
  split_graphemes(s).length().to_int64()
}

///|
pub fn string_lowercase(s : String) -> String {
  s.to_lower()
}

///|
pub fn string_uppercase(s : String) -> String {
  s.to_upper()
}

///|
pub fn string_less_than(a : String, b : String) -> Bool {
  let ia = a.iter()
  let ib = b.iter()
  while true {
    match (ia.next(), ib.next()) {
      (Some(ca), Some(cb)) =>
        if ca != cb {
          return ca < cb
        }
      (None, Some(_)) => return true
      (Some(_), None) | (None, None) => return false
    }
  }
  false
}

///|
pub fn string_grapheme_slice(
  from : String,
  index : Int64,
  length : Int64,
) -> String {
  if length <= 0L {
    return ""
  }
  let clusters = split_graphemes(from)
  let total = clusters.length()
  let mut start = index.to_int()
  if start < 0 {
    start = total + start
  }
  if start < 0 || start >= total {
    return ""
  }
  let mut end = start + length.to_int()
  if end > total {
    end = total
  }
  let buf = StringBuilder()
  let mut i = start
  while i < end {
    buf.write_string(clusters[i])
    i = i + 1
  }
  buf.to_string()
}

///|
pub fn string_byte_slice(s : String, index : Int64, length : Int64) -> String {
  if length <= 0L {
    return ""
  }
  let bytes = @utf8.encode(s)
  let total = bytes.length()
  let mut start = index.to_int()
  if start < 0 {
    start = total + start
  }
  if start < 0 || start >= total {
    return ""
  }
  let mut end = start + length.to_int()
  if end > total {
    end = total
  }
  try {
    @utf8.decode(bytes[start:end])
  } catch {
    _ => ""
  }
}

///|
pub fn string_crop(from : String, before : String) -> String {
  match from.find(before) {
    Some(idx) => from.unsafe_substring(start=idx, end=from.length())
    None => from
  }
}

///|
pub fn string_contains(haystack : String, needle : String) -> Bool {
  haystack.contains(needle)
}

///|
pub fn string_starts_with(s : String, prefix : String) -> Bool {
  s.has_prefix(prefix)
}

///|
pub fn string_ends_with(s : String, suffix : String) -> Bool {
  s.has_suffix(suffix)
}

///|
pub fn string_split_once(s : String, on : String) -> Result[(String, String), Unit] {
  match s.split_once(on) {
    Some((a, b)) => Ok((a.to_owned(), b.to_owned()))
    None => Err(())
  }
}

///|
pub fn string_trim(s : String) -> String {
  string_trim_end(string_trim_start(s))
}

///|
pub fn string_trim_start(s : String) -> String {
  s.trim_start(chars=" \t\n\r\u{000B}\u{000C}\u{0085}\u{200E}\u{200F}\u{2028}\u{2029}").to_owned()
}

///|
pub fn string_trim_end(s : String) -> String {
  s.trim_end(chars=" \t\n\r\u{000B}\u{000C}\u{0085}\u{200E}\u{200F}\u{2028}\u{2029}").to_owned()
}

///|
pub fn string_pop_grapheme(s : String) -> Result[(String, String), Unit] {
  if s == "" {
    return Err(())
  }
  let chars = s.iter().collect()
  let end = next_grapheme_end(chars, 0)
  let first_buf = StringBuilder()
  let mut i = 0
  while i < end {
    first_buf.write_char(chars[i])
    i = i + 1
  }
  let rest_buf = StringBuilder()
  while i < chars.length() {
    rest_buf.write_char(chars[i])
    i = i + 1
  }
  Ok((first_buf.to_string(), rest_buf.to_string()))
}

///|
pub fn unsafe_int_to_utf_codepoint(a : Int64) -> @gprelude.UtfCodepoint {
  { code: a }
}

///|
pub fn string_to_utf_codepoints(
  s : String,
) -> @gprelude.GList[@gprelude.UtfCodepoint] {
  let out : Array[@gprelude.UtfCodepoint] = []
  for ch in s {
    out.push({ code: ch.to_int().to_int64() })
  }
  @gprelude.GList::from_array(out[:])
}

///|
pub fn string_from_utf_codepoints(
  cps : @gprelude.GList[@gprelude.UtfCodepoint],
) -> String {
  let buf = StringBuilder()
  for cur = cps {
    match cur {
      @gprelude.Nil => break buf.to_string()
      @gprelude.Cons(cp, rest) => {
        buf.write_char(cp.code.to_int().unsafe_to_char())
        continue rest
      }
    }
  }
}

///|
pub fn utf_codepoint_to_int(cp : @gprelude.UtfCodepoint) -> Int64 {
  cp.code
}

///|
pub fn[T : @gprelude.GleamInspect] string_do_inspect(term : T) -> StringTree {
  { text: @gprelude.GleamInspect::gleam_inspect(term) }
}

///|
pub fn string_byte_size(s : String) -> Int64 {
  @utf8.encode(s).length().to_int64()
}

///|
pub fn string_remove_prefix(from : String, matching : String) -> String {
  if from.has_prefix(matching) {
    from.unsafe_substring(start=matching.length(), end=from.length())
  } else {
    from
  }
}

///|
pub fn string_remove_suffix(from : String, matching : String) -> String {
  if from.has_suffix(matching) {
    from.unsafe_substring(start=0, end=from.length() - matching.length())
  } else {
    from
  }
}

///|
pub fn string_to_graphemes(s : String) -> @gprelude.GList[String] {
  @gprelude.GList::from_array(split_graphemes(s)[:])
}

///|
pub fn string_tree_append_tree(
  tree : StringTree,
  suffix : StringTree,
) -> StringTree {
  { text: tree.text + suffix.text }
}

///|
pub fn string_tree_from_strings(xs : @gprelude.GList[String]) -> StringTree {
  let buf = StringBuilder()
  for cur = xs {
    match cur {
      @gprelude.Nil => break { text: buf.to_string() }
      @gprelude.Cons(s, rest) => {
        buf.write_string(s)
        continue rest
      }
    }
  }
}

///|
pub fn string_tree_concat(trees : @gprelude.GList[StringTree]) -> StringTree {
  let buf = StringBuilder()
  for cur = trees {
    match cur {
      @gprelude.Nil => break { text: buf.to_string() }
      @gprelude.Cons(t, rest) => {
        buf.write_string(t.text)
        continue rest
      }
    }
  }
}

///|
pub fn string_tree_from_string(s : String) -> StringTree {
  { text: s }
}

///|
pub fn string_tree_to_string(tree : StringTree) -> String {
  tree.text
}

///|
pub fn string_tree_byte_size(tree : StringTree) -> Int64 {
  @utf8.encode(tree.text).length().to_int64()
}

///|
pub fn string_tree_lowercase(tree : StringTree) -> StringTree {
  { text: tree.text.to_lower() }
}

///|
pub fn string_tree_uppercase(tree : StringTree) -> StringTree {
  { text: tree.text.to_upper() }
}

///|
pub fn string_tree_split(
  tree : StringTree,
  pattern : String,
) -> @gprelude.GList[StringTree] {
  let out : Array[StringTree] = []
  if pattern == "" {
    for g in split_graphemes(tree.text) {
      out.push({ text: g })
    }
  } else {
    for part in tree.text.split(pattern) {
      out.push({ text: part.to_owned() })
    }
  }
  @gprelude.GList::from_array(out[:])
}

///|
pub fn string_tree_replace(
  tree : StringTree,
  pattern : String,
  substitute : String,
) -> StringTree {
  { text: tree.text.replace_all(old=pattern, new=substitute) }
}
