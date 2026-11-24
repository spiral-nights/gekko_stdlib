///|
pub fn length(s : String) -> Int64 {
  @string_tree.__split_graphemes(s).length().to_int64()
}

///|
pub fn lowercase(s : String) -> String {
  s.to_lower()
}

///|
pub fn uppercase(s : String) -> String {
  s.to_upper()
}

///|
pub fn less_than(a : String, b : String) -> Bool {
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
pub fn grapheme_slice(
  from : String,
  index : Int64,
  length : Int64,
) -> String {
  if length <= 0L {
    return ""
  }
  let clusters = @string_tree.__split_graphemes(from)
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
fn unsafe_byte_slice(s : String, index : Int64, length : Int64) -> String {
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
pub fn crop(from : String, before : String) -> String {
  match from.find(before) {
    Some(idx) => from.unsafe_substring(start=idx, end=from.length())
    None => from
  }
}

///|
pub fn contains(haystack : String, needle : String) -> Bool {
  haystack.contains(needle)
}

///|
pub fn starts_with(s : String, prefix : String) -> Bool {
  s.has_prefix(prefix)
}

///|
pub fn ends_with(s : String, suffix : String) -> Bool {
  s.has_suffix(suffix)
}

///|
pub fn split_once(s : String, on : String) -> Result[(String, String), Unit] {
  match s.split_once(on) {
    Some((a, b)) => Ok((a.to_owned(), b.to_owned()))
    None => Err(())
  }
}

///|
pub fn trim(s : String) -> String {
  trim_end(trim_start(s))
}

///|
pub fn trim_start(s : String) -> String {
  s.trim_start(chars=" \t\n\r\u{000B}\u{000C}\u{0085}\u{200E}\u{200F}\u{2028}\u{2029}").to_owned()
}

///|
pub fn trim_end(s : String) -> String {
  s.trim_end(chars=" \t\n\r\u{000B}\u{000C}\u{0085}\u{200E}\u{200F}\u{2028}\u{2029}").to_owned()
}

///|
pub fn pop_grapheme(s : String) -> Result[(String, String), Unit] {
  if s == "" {
    return Err(())
  }
  let chars = s.iter().collect()
  let end = @string_tree.__next_grapheme_end(chars, 0)
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
fn unsafe_int_to_utf_codepoint(a : Int64) -> @gprelude.UtfCodepoint {
  { code: a }
}

///|
pub fn to_utf_codepoints(
  s : String,
) -> @gprelude.GList[@gprelude.UtfCodepoint] {
  let out : Array[@gprelude.UtfCodepoint] = []
  for ch in s {
    out.push({ code: ch.to_int().to_int64() })
  }
  @gprelude.GList::from_array(out[:])
}

///|
pub fn from_utf_codepoints(
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
pub fn[T : @gprelude.GleamInspect] do_inspect(term : T) -> @string_tree.StringTree {
  { text: @gprelude.GleamInspect::gleam_inspect(term) }
}

///|
pub fn byte_size(s : String) -> Int64 {
  @utf8.encode(s).length().to_int64()
}

///|
pub fn remove_prefix(from : String, matching : String) -> String {
  if from.has_prefix(matching) {
    from.unsafe_substring(start=matching.length(), end=from.length())
  } else {
    from
  }
}

///|
pub fn remove_suffix(from : String, matching : String) -> String {
  if from.has_suffix(matching) {
    from.unsafe_substring(start=0, end=from.length() - matching.length())
  } else {
    from
  }
}

