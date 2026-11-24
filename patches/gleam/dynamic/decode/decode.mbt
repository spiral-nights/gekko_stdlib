///|
fn[T] __patch_reverse_glist(xs : @gprelude.GList[T]) -> @gprelude.GList[T] {
  for cur = xs, acc = @gprelude.Nil {
    match cur {
      @gprelude.Nil => break acc
      @gprelude.Cons(x, rest) => continue rest, @gprelude.Cons(x, acc)
    }
  }
}

///|
#gekko.patch
fn[K : @gprelude.ToDynamic] lookup_field(
  data : @gprelude.Dynamic,
  key : K,
) -> Lookup {
  let dk = @gprelude.ToDynamic::to_dynamic(key)
  match (data, dk) {
    (@gprelude.DynMap(m), _) =>
      match m.get(dk) {
        Some(child) => Found(value=child)
        None => Missing
      }
    (@gprelude.DynArray(arr), @gprelude.DynInt(idx)) =>
      if idx >= 0L && idx.to_int() < arr.length() {
        Found(value=arr[idx.to_int()])
      } else {
        Missing
      }
    (@gprelude.DynList(xs), @gprelude.DynInt(idx)) =>
      if idx < 0L {
        Missing
      } else {
        for cur = xs, i = 0L {
          match cur {
            @gprelude.Nil => break Missing
            @gprelude.Cons(v, rest) =>
              if i == idx {
                break Found(value=v)
              } else {
                continue rest, i + 1L
              }
          }
        }
      }
    (@gprelude.DynArray(_), _) | (@gprelude.DynList(_), _) => Missing
    (_, @gprelude.DynInt(_)) => InvalidIndex
    _ => InvalidKey
  }
}

///|
#gekko.patch
fn[K : @gprelude.ToDynamic] key_to_string(key : K) -> String {
  match @gprelude.ToDynamic::to_dynamic(key) {
    @gprelude.DynString(s) => s
    @gprelude.DynInt(i) => i.to_string()
    @gprelude.DynFloat(f) => f.to_string()
    other => "<" + @dynamic.classify(other) + ">"
  }
}

///|
#gekko.patch
fn decode_string(
  data : @gprelude.Dynamic,
) -> (String, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynString(s) => (s, @gprelude.Nil)
    _ => ("", decode_error("String", data))
  }
}

///|
#gekko.patch
fn decode_bool(
  data : @gprelude.Dynamic,
) -> (Bool, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynBool(b) => (b, @gprelude.Nil)
    _ => (false, decode_error("Bool", data))
  }
}

///|
#gekko.patch
fn decode_int(
  data : @gprelude.Dynamic,
) -> (Int64, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynInt(i) => (i, @gprelude.Nil)
    _ => (0L, decode_error("Int", data))
  }
}

///|
#gekko.patch
fn decode_float(
  data : @gprelude.Dynamic,
) -> (Double, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynFloat(f) => (f, @gprelude.Nil)
    _ => (0.0, decode_error("Float", data))
  }
}

///|
#gekko.patch
fn decode_bit_array(
  data : @gprelude.Dynamic,
) -> (@gprelude.BitArray, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynBitArray(ba) => (ba, @gprelude.Nil)
    _ => (@gprelude.BitArray::empty(), decode_error("BitArray", data))
  }
}

///|
#gekko.patch
pub fn[A] list(inner : Decoder[A]) -> Decoder[@gprelude.GList[A]] {
  Decoder(function=fn(data) {
    let elements_res = match data {
      @gprelude.DynList(xs) => Ok(xs)
      @gprelude.DynArray(arr) => Ok(@gprelude.GList::from_array(arr[:]))
      _ => Err(())
    }
    match elements_res {
      Err(_) => (@gprelude.Nil, decode_error("List", data))
      Ok(elements) =>
        for cur = elements, idx = 0L, acc = @gprelude.Nil {
          match cur {
            @gprelude.Nil => break (__patch_reverse_glist(acc), @gprelude.Nil)
            @gprelude.Cons(element, rest) =>
              match (inner.function())(element) {
                (decoded, @gprelude.Nil) =>
                  continue rest, idx + 1L, @gprelude.Cons(decoded, acc)
                (_, errors) => break (@gprelude.Nil, prefix_errors(idx, errors))
              }
          }
        }
    }
  })
}

///|
#gekko.patch
fn[K, V] decode_dict(
  data : @gprelude.Dynamic,
  decode_entry : (
    @dict.Dict[K, V],
    @gprelude.Dynamic,
    @gprelude.Dynamic,
  ) -> (@dict.Dict[K, V], @gprelude.GList[DecodeError]),
) -> (@dict.Dict[K, V], @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynMap(raw_map) => {
      let mut acc : (@dict.Dict[K, V], @gprelude.GList[DecodeError]) = (
        @dict.new(),
        @gprelude.Nil,
      )
      raw_map.each(fn(k, v) {
        match acc.1 {
          @gprelude.Nil => acc = decode_entry(acc.0, k, v)
          _ => ()
        }
      })
      acc
    }
    _ => (@dict.new(), decode_error("Dict", data))
  }
}

///|
#gekko.patch
fn is_null(a : @gprelude.Dynamic) -> Bool {
  match a {
    @gprelude.DynNull => true
    _ => false
  }
}
