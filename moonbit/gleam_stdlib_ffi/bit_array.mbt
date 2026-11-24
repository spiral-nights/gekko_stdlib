///|
pub fn bit_array_from_string(x : String) -> @gprelude.BitArray {
  @gprelude.BitArray::from_string(x)
}

///|
pub fn bit_array_bit_size(x : @gprelude.BitArray) -> Int64 {
  x.bit_size()
}

///|
pub fn bit_array_byte_size(x : @gprelude.BitArray) -> Int64 {
  x.byte_size()
}

///|
pub fn bit_array_pad_to_bytes(x : @gprelude.BitArray) -> @gprelude.BitArray {
  x.pad_to_bytes()
}

///|
pub fn bit_array_slice(
  bits : @gprelude.BitArray,
  at : Int64,
  take : Int64,
) -> Result[@gprelude.BitArray, Unit] {
  if bits.bit_length % 8L != 0L || at < 0L {
    return Err(())
  }
  let len = bits.data.length().to_int64()
  let (start, count) = if take < 0L {
    (at + take, -take)
  } else {
    (at, take)
  }
  if start < 0L || start + count > len {
    Err(())
  } else {
    let view = bits.data[start.to_int():(start + count).to_int()]
    Ok(@gprelude.BitArray::from_bytes(Bytes::from_iter(view.iter())))
  }
}

///|
pub fn bit_array_is_utf8(bits : @gprelude.BitArray) -> Bool {
  if bits.bit_length % 8L != 0L {
    return false
  }
  try {
    @prelude.ignore(@utf8.decode(bits.data[:]))
    true
  } catch {
    _ => false
  }
}

///|
pub fn bit_array_to_string(bits : @gprelude.BitArray) -> Result[String, Unit] {
  if bits.bit_length % 8L != 0L {
    return Err(())
  }
  try {
    Ok(@utf8.decode(bits.data[:]))
  } catch {
    _ => Err(())
  }
}

///|
pub fn bit_array_concat(
  bit_arrays : @gprelude.GList[@gprelude.BitArray],
) -> @gprelude.BitArray {
  @gprelude.BitArray::concat(bit_arrays.to_array()[:])
}

///|
pub fn bit_array_base64_encode(
  input : @gprelude.BitArray,
  padding : Bool,
) -> String {
  let alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  let data = input.data
  let len = data.length()
  let buf = StringBuilder()
  let mut i = 0
  while i < len {
    let b0 = data[i].to_int()
    let has1 = i + 1 < len
    let has2 = i + 2 < len
    let b1 = if has1 { data[i + 1].to_int() } else { 0 }
    let b2 = if has2 { data[i + 2].to_int() } else { 0 }
    let triple = (b0 << 16) | (b1 << 8) | b2
    buf.write_char(alpha[(triple >> 18) & 0x3F].to_int().unsafe_to_char())
    buf.write_char(alpha[(triple >> 12) & 0x3F].to_int().unsafe_to_char())
    if has1 {
      buf.write_char(alpha[(triple >> 6) & 0x3F].to_int().unsafe_to_char())
    } else if padding {
      buf.write_char('=')
    }
    if has2 {
      buf.write_char(alpha[triple & 0x3F].to_int().unsafe_to_char())
    } else if padding {
      buf.write_char('=')
    }
    i = i + 3
  }
  buf.to_string()
}

///|
fn b64_val(c : Char) -> Int {
  if c >= 'A' && c <= 'Z' {
    c.to_int() - 'A'.to_int()
  } else if c >= 'a' && c <= 'z' {
    c.to_int() - 'a'.to_int() + 26
  } else if c >= '0' && c <= '9' {
    c.to_int() - '0'.to_int() + 52
  } else if c == '+' {
    62
  } else if c == '/' {
    63
  } else {
    -1
  }
}

///|
pub fn bit_array_base64_decode(
  input : String,
) -> Result[@gprelude.BitArray, Unit] {
  if input == "" {
    return Ok(@gprelude.BitArray::empty())
  }
  let chars = input.iter().collect()
  let len = chars.length()
  if len % 4 != 0 {
    return Err(())
  }
  let buf = @buffer.Buffer()
  let mut i = 0
  while i < len {
    let c0 = chars[i]
    let c1 = chars[i + 1]
    let c2 = chars[i + 2]
    let c3 = chars[i + 3]
    let v0 = b64_val(c0)
    let v1 = b64_val(c1)
    if v0 < 0 || v1 < 0 {
      return Err(())
    }
    let is_last = i + 4 == len
    if c2 == '=' {
      if !is_last || c3 != '=' {
        return Err(())
      }
      buf.write_byte(((v0 << 2) | (v1 >> 4)).to_byte())
    } else if c3 == '=' {
      if !is_last {
        return Err(())
      }
      let v2 = b64_val(c2)
      if v2 < 0 {
        return Err(())
      }
      buf.write_byte(((v0 << 2) | (v1 >> 4)).to_byte())
      buf.write_byte((((v1 & 0xF) << 4) | (v2 >> 2)).to_byte())
    } else {
      let v2 = b64_val(c2)
      let v3 = b64_val(c3)
      if v2 < 0 || v3 < 0 {
        return Err(())
      }
      buf.write_byte(((v0 << 2) | (v1 >> 4)).to_byte())
      buf.write_byte((((v1 & 0xF) << 4) | (v2 >> 2)).to_byte())
      buf.write_byte((((v2 & 0x3) << 6) | v3).to_byte())
    }
    i = i + 4
  }
  Ok(@gprelude.BitArray::from_bytes(buf.to_bytes()))
}

///|
pub fn bit_array_base16_encode(input : @gprelude.BitArray) -> String {
  let hex = "0123456789ABCDEF"
  let buf = StringBuilder()
  for b in input.data {
    let v = b.to_int()
    buf.write_char(hex[v >> 4].to_int().unsafe_to_char())
    buf.write_char(hex[v & 0xF].to_int().unsafe_to_char())
  }
  buf.to_string()
}

///|
fn hex_val(c : Char) -> Int {
  if c >= '0' && c <= '9' {
    c.to_int() - '0'.to_int()
  } else if c >= 'a' && c <= 'f' {
    c.to_int() - 'a'.to_int() + 10
  } else if c >= 'A' && c <= 'F' {
    c.to_int() - 'A'.to_int() + 10
  } else {
    -1
  }
}

///|
pub fn bit_array_base16_decode(
  input : String,
) -> Result[@gprelude.BitArray, Unit] {
  let chars = input.iter().collect()
  if chars.length() % 2 != 0 {
    return Err(())
  }
  let buf = @buffer.Buffer()
  let mut i = 0
  while i < chars.length() {
    let hi = hex_val(chars[i])
    let lo = hex_val(chars[i + 1])
    if hi < 0 || lo < 0 {
      return Err(())
    }
    buf.write_byte(((hi << 4) | lo).to_byte())
    i = i + 2
  }
  Ok(@gprelude.BitArray::from_bytes(buf.to_bytes()))
}

///|
pub fn bit_array_inspect(input : @gprelude.BitArray) -> String {
  @gprelude.GleamInspect::gleam_inspect(input)
}

///|
fn compare_tail_val(
  ba : @gprelude.BitArray,
  byte_off : Int,
  rem_bits : Int64,
) -> Int {
  if rem_bits < 8L {
    ba.data[byte_off].to_int() >> (8 - rem_bits.to_int())
  } else {
    let high_bits = rem_bits - 7L
    let hb_bytes = (high_bits / 8L).to_int()
    let hb_rem = (high_bits % 8L).to_int()
    let mut i = 0
    while i < hb_bytes {
      if ba.data[byte_off + i] != b'\x00' {
        return 256
      }
      i = i + 1
    }
    if hb_rem > 0 {
      let mask = 0xFF ^ ((1 << (8 - hb_rem)) - 1)
      if (ba.data[byte_off + hb_bytes].to_int() & mask) != 0 {
        return 256
      }
    }
    match
      @gprelude.bit_array_read_int(
        ba,
        byte_off.to_int64() * 8L + high_bits,
        7L,
        false,
        true,
      ) {
      Some(v) => v.to_int()
      None => 0
    }
  }
}

///|
pub fn bit_array_compare(
  a : @gprelude.BitArray,
  b : @gprelude.BitArray,
) -> @gleam_order.Order {
  let full_a = (a.bit_length / 8L).to_int()
  let full_b = (b.bit_length / 8L).to_int()
  let min_bytes = if full_a < full_b { full_a } else { full_b }
  let mut i = 0
  while i < min_bytes {
    let ba = a.data[i].to_int()
    let bb = b.data[i].to_int()
    if ba < bb {
      return @gleam_order.Lt
    } else if ba > bb {
      return @gleam_order.Gt
    }
    i = i + 1
  }
  let consumed_bits = min_bytes.to_int64() * 8L
  let rem_a = a.bit_length - consumed_bits
  let rem_b = b.bit_length - consumed_bits
  if rem_a == 0L && rem_b == 0L {
    @gleam_order.Eq
  } else if rem_b == 0L {
    @gleam_order.Gt
  } else if rem_a == 0L {
    @gleam_order.Lt
  } else {
    let va = compare_tail_val(a, min_bytes, rem_a)
    let vb = compare_tail_val(b, min_bytes, rem_b)
    if va < vb {
      @gleam_order.Lt
    } else if va > vb {
      @gleam_order.Gt
    } else if rem_a > rem_b {
      @gleam_order.Gt
    } else if rem_a < rem_b {
      @gleam_order.Lt
    } else {
      @gleam_order.Eq
    }
  }
}

///|
pub fn bit_array_starts_with(
  bits : @gprelude.BitArray,
  prefix : @gprelude.BitArray,
) -> Bool {
  if prefix.bit_length > bits.bit_length {
    return false
  }
  let full_bytes = (prefix.bit_length / 8L).to_int()
  let rem = (prefix.bit_length % 8L).to_int()
  let mut i = 0
  while i < full_bytes {
    if bits.data[i] != prefix.data[i] {
      return false
    }
    i = i + 1
  }
  if rem > 0 {
    let shift = 8 - rem
    if (bits.data[full_bytes].to_int() >> shift) !=
      (prefix.data[full_bytes].to_int() >> shift) {
      return false
    }
  }
  true
}
