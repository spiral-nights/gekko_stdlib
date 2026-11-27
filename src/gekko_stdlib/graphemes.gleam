import gekko_stdlib/ffi/builtin as mbuiltin
import gleam/option.{None}

fn is_gcb_hangul_l(cp: Int) -> Bool {
  { cp >= 0x1100 && cp <= 0x115F } || { cp >= 0xA960 && cp <= 0xA97C }
}

fn is_gcb_hangul_v(cp: Int) -> Bool {
  { cp >= 0x1160 && cp <= 0x11A7 } || { cp >= 0xD7B0 && cp <= 0xD7C6 }
}

fn is_gcb_hangul_t(cp: Int) -> Bool {
  { cp >= 0x11A8 && cp <= 0x11FF } || { cp >= 0xD7CB && cp <= 0xD7FB }
}

fn is_gcb_hangul_lv(cp: Int) -> Bool {
  cp >= 0xAC00 && cp <= 0xD7A3 && { cp - 0xAC00 } % 28 == 0
}

fn is_gcb_hangul_lvt(cp: Int) -> Bool {
  cp >= 0xAC00 && cp <= 0xD7A3 && { cp - 0xAC00 } % 28 != 0
}

fn is_gcb_control(cp: Int) -> Bool {
  { cp >= 0x0000 && cp <= 0x001F && cp != 0x000A && cp != 0x000D }
  || { cp >= 0x007F && cp <= 0x009F }
  || cp == 0x00AD
  || cp == 0x061C
  || cp == 0x200B
  || { cp >= 0x200E && cp <= 0x200F }
  || { cp >= 0x2028 && cp <= 0x202E }
  || { cp >= 0x2060 && cp <= 0x206F }
  || cp == 0xFEFF
  || { cp >= 0xFFF0 && cp <= 0xFFFB }
}

fn is_gcb_prepend(cp: Int) -> Bool {
  { cp >= 0x0600 && cp <= 0x0605 }
  || cp == 0x06DD
  || cp == 0x070F
  || { cp >= 0x0890 && cp <= 0x0891 }
  || cp == 0x08E2
  || cp == 0x0D4E
  || cp == 0x110BD
  || cp == 0x110CD
  || { cp >= 0x111C2 && cp <= 0x111C3 }
}

fn is_gcb_extend(cp: Int) -> Bool {
  { cp >= 0x0300 && cp <= 0x036F }
  || { cp >= 0x0483 && cp <= 0x0489 }
  || { cp >= 0x0591 && cp <= 0x05BD }
  || cp == 0x05BF
  || { cp >= 0x05C1 && cp <= 0x05C2 }
  || { cp >= 0x05C4 && cp <= 0x05C5 }
  || cp == 0x05C7
  || { cp >= 0x0610 && cp <= 0x061A }
  || { cp >= 0x064B && cp <= 0x065F }
  || cp == 0x0670
  || { cp >= 0x06D6 && cp <= 0x06DC }
  || { cp >= 0x06DF && cp <= 0x06E4 }
  || { cp >= 0x06E7 && cp <= 0x06E8 }
  || { cp >= 0x06EA && cp <= 0x06ED }
  || cp == 0x0711
  || { cp >= 0x0730 && cp <= 0x074A }
  || { cp >= 0x07A6 && cp <= 0x07B0 }
  || { cp >= 0x07EB && cp <= 0x07F3 }
  || { cp >= 0x0816 && cp <= 0x0819 }
  || { cp >= 0x081B && cp <= 0x0823 }
  || { cp >= 0x0825 && cp <= 0x0827 }
  || { cp >= 0x0829 && cp <= 0x082D }
  || { cp >= 0x08D3 && cp <= 0x08E1 }
  || { cp >= 0x08E3 && cp <= 0x0902 }
  || cp == 0x093A
  || cp == 0x093C
  || { cp >= 0x0941 && cp <= 0x0948 }
  || cp == 0x094D
  || { cp >= 0x0951 && cp <= 0x0957 }
  || { cp >= 0x0962 && cp <= 0x0963 }
  || cp == 0x0981
  || cp == 0x09BC
  || cp == 0x09BE
  || { cp >= 0x09C1 && cp <= 0x09C4 }
  || cp == 0x09CD
  || cp == 0x09D7
  || { cp >= 0x09E2 && cp <= 0x09E3 }
  || { cp >= 0x0E31 && cp <= 0x0E3A && cp != 0x0E32 && cp != 0x0E33 }
  || { cp >= 0x0E47 && cp <= 0x0E4E }
  || cp == 0x0EB1
  || { cp >= 0x0EB4 && cp <= 0x0EBC }
  || { cp >= 0x0EC8 && cp <= 0x0ECD }
  || { cp >= 0x0F71 && cp <= 0x0F7E }
  || { cp >= 0x0F80 && cp <= 0x0F84 }
  || { cp >= 0x0F86 && cp <= 0x0F87 }
  || { cp >= 0x0F8D && cp <= 0x0FBC }
  || { cp >= 0x102D && cp <= 0x1030 }
  || { cp >= 0x1032 && cp <= 0x1037 }
  || { cp >= 0x1039 && cp <= 0x103A }
  || { cp >= 0x1AB0 && cp <= 0x1ACE }
  || { cp >= 0x1DC0 && cp <= 0x1DFF }
  || cp == 0x200C
  || { cp >= 0x20D0 && cp <= 0x20F0 }
  || { cp >= 0x2DE0 && cp <= 0x2DFF }
  || { cp >= 0x302A && cp <= 0x302F }
  || { cp >= 0x3099 && cp <= 0x309A }
  || { cp >= 0xA674 && cp <= 0xA67D }
  || { cp >= 0xFE00 && cp <= 0xFE0F }
  || { cp >= 0xFE20 && cp <= 0xFE2F }
  || { cp >= 0xFF9E && cp <= 0xFF9F }
  || { cp >= 0x1F3FB && cp <= 0x1F3FF }
  || { cp >= 0xE0020 && cp <= 0xE007F }
  || { cp >= 0xE0100 && cp <= 0xE01EF }
}

fn is_gcb_spacing_mark(cp: Int) -> Bool {
  cp == 0x0903
  || cp == 0x093B
  || { cp >= 0x093E && cp <= 0x0940 }
  || { cp >= 0x0949 && cp <= 0x094C }
  || { cp >= 0x094E && cp <= 0x094F }
  || { cp >= 0x0982 && cp <= 0x0983 }
  || { cp >= 0x09BF && cp <= 0x09C0 }
  || { cp >= 0x09C7 && cp <= 0x09C8 }
  || { cp >= 0x09CB && cp <= 0x09CC }
}

fn is_gcb_ri(cp: Int) -> Bool {
  cp >= 0x1F1E6 && cp <= 0x1F1FF
}

fn is_gcb_ext_pict(cp: Int) -> Bool {
  cp == 0x00A9
  || cp == 0x00AE
  || cp == 0x203C
  || cp == 0x2049
  || cp == 0x2122
  || cp == 0x2139
  || { cp >= 0x2194 && cp <= 0x2199 }
  || { cp >= 0x21A9 && cp <= 0x21AA }
  || { cp >= 0x231A && cp <= 0x231B }
  || cp == 0x2328
  || cp == 0x23CF
  || { cp >= 0x23E9 && cp <= 0x23F3 }
  || { cp >= 0x23F8 && cp <= 0x23FA }
  || cp == 0x24C2
  || { cp >= 0x25AA && cp <= 0x25AB }
  || cp == 0x25B6
  || cp == 0x25C0
  || { cp >= 0x25FB && cp <= 0x25FE }
  || { cp >= 0x2600 && cp <= 0x27BF }
  || { cp >= 0x2934 && cp <= 0x2935 }
  || { cp >= 0x2B05 && cp <= 0x2B07 }
  || { cp >= 0x2B1B && cp <= 0x2B1C }
  || cp == 0x2B50
  || cp == 0x2B55
  || cp == 0x3030
  || cp == 0x303D
  || cp == 0x3297
  || cp == 0x3299
  || {
    cp >= 0x1F000
    && cp <= 0x1FAFF
    && !is_gcb_ri(cp)
    && !{ cp >= 0x1F3FB && cp <= 0x1F3FF }
  }
}

fn take_cluster_rest(
  chars: List(UtfCodepoint),
  buf: mbuiltin.StringBuilder,
  prev: Int,
  ri_odd: Bool,
  ext_pict_zwj: Bool,
  saw_zwj: Bool,
) -> #(String, List(UtfCodepoint)) {
  case chars {
    [] -> #(mbuiltin.string_builder_to_string(buf), [])
    [ch, ..rest] -> {
      let cur = mbuiltin.char_to_int(ch)
      case cur == 0x0D || cur == 0x0A || is_gcb_control(cur) {
        True -> #(mbuiltin.string_builder_to_string(buf), chars)
        False -> {
          let is_hangul =
            {
              is_gcb_hangul_l(prev)
              && {
                is_gcb_hangul_l(cur)
                || is_gcb_hangul_v(cur)
                || is_gcb_hangul_lv(cur)
                || is_gcb_hangul_lvt(cur)
              }
            }
            || {
              { is_gcb_hangul_lv(prev) || is_gcb_hangul_v(prev) }
              && { is_gcb_hangul_v(cur) || is_gcb_hangul_t(cur) }
            }
            || {
              { is_gcb_hangul_lvt(prev) || is_gcb_hangul_t(prev) }
              && is_gcb_hangul_t(cur)
            }
          case is_hangul {
            True -> {
              mbuiltin.write_char(buf, ch)
              take_cluster_rest(rest, buf, cur, ri_odd, ext_pict_zwj, saw_zwj)
            }
            False ->
              case is_gcb_extend(cur) {
                True -> {
                  mbuiltin.write_char(buf, ch)
                  take_cluster_rest(
                    rest,
                    buf,
                    cur,
                    ri_odd,
                    ext_pict_zwj,
                    saw_zwj,
                  )
                }
                False ->
                  case cur == 0x200D {
                    True -> {
                      mbuiltin.write_char(buf, ch)
                      take_cluster_rest(
                        rest,
                        buf,
                        cur,
                        ri_odd,
                        ext_pict_zwj,
                        True,
                      )
                    }
                    False ->
                      case is_gcb_spacing_mark(cur) {
                        True -> {
                          mbuiltin.write_char(buf, ch)
                          take_cluster_rest(
                            rest,
                            buf,
                            cur,
                            ri_odd,
                            False,
                            False,
                          )
                        }
                        False ->
                          case is_gcb_prepend(prev) {
                            True -> {
                              mbuiltin.write_char(buf, ch)
                              take_cluster_rest(
                                rest,
                                buf,
                                cur,
                                is_gcb_ri(cur),
                                is_gcb_ext_pict(cur),
                                False,
                              )
                            }
                            False ->
                              case
                                ext_pict_zwj && saw_zwj && is_gcb_ext_pict(cur)
                              {
                                True -> {
                                  mbuiltin.write_char(buf, ch)
                                  take_cluster_rest(
                                    rest,
                                    buf,
                                    cur,
                                    ri_odd,
                                    ext_pict_zwj,
                                    False,
                                  )
                                }
                                False ->
                                  case is_gcb_ri(cur) && ri_odd {
                                    True -> {
                                      mbuiltin.write_char(buf, ch)
                                      take_cluster_rest(
                                        rest,
                                        buf,
                                        cur,
                                        False,
                                        ext_pict_zwj,
                                        saw_zwj,
                                      )
                                    }
                                    False -> #(
                                      mbuiltin.string_builder_to_string(buf),
                                      chars,
                                    )
                                  }
                              }
                          }
                      }
                  }
              }
          }
        }
      }
    }
  }
}

fn pop_cluster_chars(
  chars: List(UtfCodepoint),
) -> Result(#(String, List(UtfCodepoint)), Nil) {
  case chars {
    [] -> Error(Nil)
    [c0, ..rest] -> {
      let cp0 = mbuiltin.char_to_int(c0)
      let buf = mbuiltin.new_string_builder(None)
      mbuiltin.write_char(buf, c0)
      case rest {
        [] -> Ok(#(mbuiltin.string_builder_to_string(buf), []))
        [c1, ..rest1] -> {
          let cp1 = mbuiltin.char_to_int(c1)
          case cp0 == 0x0D && cp1 == 0x0A {
            True -> {
              mbuiltin.write_char(buf, c1)
              Ok(#(mbuiltin.string_builder_to_string(buf), rest1))
            }
            False ->
              case cp0 == 0x0D || cp0 == 0x0A || is_gcb_control(cp0) {
                True -> Ok(#(mbuiltin.string_builder_to_string(buf), rest))
                False ->
                  Ok(take_cluster_rest(
                    rest,
                    buf,
                    cp0,
                    is_gcb_ri(cp0),
                    is_gcb_ext_pict(cp0),
                    cp0 == 0x200D,
                  ))
              }
          }
        }
      }
    }
  }
}

fn reverse_loop(xs: List(a), acc: List(a)) -> List(a) {
  case xs {
    [] -> acc
    [h, ..t] -> reverse_loop(t, [h, ..acc])
  }
}

fn split_chars_loop(
  chars: List(UtfCodepoint),
  acc: List(String),
) -> List(String) {
  case pop_cluster_chars(chars) {
    Error(_) -> reverse_loop(acc, [])
    Ok(#(cluster, rest)) -> split_chars_loop(rest, [cluster, ..acc])
  }
}

pub fn split(s: String) -> List(String) {
  split_chars_loop(mbuiltin.string_to_array(s), [])
}

pub fn pop(s: String) -> Result(#(String, String), Nil) {
  case pop_cluster_chars(mbuiltin.string_to_array(s)) {
    Error(_) -> Error(Nil)
    Ok(#(first, rest)) -> Ok(#(first, mbuiltin.string_from_array(rest)))
  }
}
