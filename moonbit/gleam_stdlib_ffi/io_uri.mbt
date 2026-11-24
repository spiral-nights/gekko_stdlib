///|
pub fn io_print(s : String) -> Unit {
  @prelude.println(s)
}

///|
pub fn io_print_error(s : String) -> Unit {
  @prelude.eprintln(s)
}

///|
pub fn io_println(s : String) -> Unit {
  @prelude.println(s)
}

///|
pub fn io_println_error(s : String) -> Unit {
  @prelude.eprintln(s)
}

///|
pub fn uri_pop_codeunit(str : String) -> (Int64, String) {
  if str == "" {
    (0L, "")
  } else {
    (
      str[0].to_int().to_int64(),
      str.unsafe_substring(start=1, end=str.length()),
    )
  }
}

///|
pub fn uri_codeunit_slice(
  str : String,
  from : Int64,
  length : Int64,
) -> String {
  if length <= 0L {
    return ""
  }
  let total = str.length()
  let mut start = from.to_int()
  if start < 0 {
    start = 0
  }
  if start >= total {
    return ""
  }
  let mut end = start + length.to_int()
  if end > total {
    end = total
  }
  str.unsafe_substring(start=start, end=end)
}

///|
fn is_unreserved_byte(b : Byte) -> Bool {
  let v = b.to_int()
  (v >= 'A'.to_int() && v <= 'Z'.to_int()) ||
  (v >= 'a'.to_int() && v <= 'z'.to_int()) ||
  (v >= '0'.to_int() && v <= '9'.to_int()) ||
  v == '-'.to_int() ||
  v == '_'.to_int() ||
  v == '.'.to_int() ||
  v == '~'.to_int() ||
  v == '!'.to_int() ||
  v == '\''.to_int() ||
  v == '('.to_int() ||
  v == ')'.to_int() ||
  v == '*'.to_int() ||
  v == '+'.to_int()
}

///|
pub fn uri_percent_encode(value : String) -> String {
  let hex = "0123456789ABCDEF"
  let bytes = @utf8.encode(value)
  let buf = StringBuilder()
  for b in bytes {
    if is_unreserved_byte(b) {
      buf.write_char(b.to_int().unsafe_to_char())
    } else {
      let v = b.to_int()
      buf.write_char('%')
      buf.write_char(hex[v >> 4].to_int().unsafe_to_char())
      buf.write_char(hex[v & 0xF].to_int().unsafe_to_char())
    }
  }
  buf.to_string()
}

///|
fn uri_hex_val(b : Byte) -> Int {
  let v = b.to_int()
  if v >= '0'.to_int() && v <= '9'.to_int() {
    v - '0'.to_int()
  } else if v >= 'a'.to_int() && v <= 'f'.to_int() {
    v - 'a'.to_int() + 10
  } else if v >= 'A'.to_int() && v <= 'F'.to_int() {
    v - 'A'.to_int() + 10
  } else {
    -1
  }
}

///|
fn percent_decode_bytes(
  value : String,
  plus_as_space : Bool,
) -> Result[String, Unit] {
  let bytes = @utf8.encode(value)
  let len = bytes.length()
  let buf = @buffer.Buffer()
  let mut i = 0
  while i < len {
    let b = bytes[i]
    if b == b'%' {
      if i + 2 >= len {
        return Err(())
      }
      let hi = uri_hex_val(bytes[i + 1])
      let lo = uri_hex_val(bytes[i + 2])
      if hi < 0 || lo < 0 {
        return Err(())
      }
      buf.write_byte(((hi << 4) | lo).to_byte())
      i = i + 3
    } else if plus_as_space && b == b'+' {
      buf.write_byte(b' ')
      i = i + 1
    } else {
      buf.write_byte(b)
      i = i + 1
    }
  }
  try {
    Ok(@utf8.decode(buf.to_bytes()[:]))
  } catch {
    _ => Err(())
  }
}

///|
pub fn uri_percent_decode(value : String) -> Result[String, Unit] {
  percent_decode_bytes(value, false)
}

///|
pub fn uri_parse_query(
  query : String,
) -> Result[@gprelude.GList[(String, String)], Unit] {
  if query == "" {
    return Ok(@gprelude.Nil)
  }
  let pairs : Array[(String, String)] = []
  for part_view in query.split("&") {
    let part = part_view.to_owned()
    if part == "" {
      continue
    }
    let (raw_k, raw_v) = match part.split_once("=") {
      Some((k, v)) => (k.to_owned(), v.to_owned())
      None => (part, "")
    }
    match
      (percent_decode_bytes(raw_k, true), percent_decode_bytes(raw_v, true)) {
      (Ok(k), Ok(v)) => pairs.push((k, v))
      _ => return Err(())
    }
  }
  Ok(@gprelude.GList::from_array(pairs[:]))
}
