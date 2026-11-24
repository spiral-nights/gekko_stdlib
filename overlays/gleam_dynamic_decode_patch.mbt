///|
fn[T] __shim_reverse_glist(xs : @gprelude.GList[T]) -> @gprelude.GList[T] {
  for cur = xs, acc = @gprelude.Nil {
    match cur {
      @gprelude.Nil => break acc
      @gprelude.Cons(x, rest) => continue rest, @gprelude.Cons(x, acc)
    }
  }
}

///|
fn[K : @gprelude.ToDynamic] __shim_lookup_field(
  data : @gprelude.Dynamic,
  key : K,
) -> Lookup {
  match @gleam_stdlib_ffi.decode_bare_index(data, key) {
    Ok(Some(child)) => Found(value=child)
    Ok(None) => Missing
    Err("Indexable") => InvalidIndex
    Err(_) => InvalidKey
  }
}

///|
fn[K : @gprelude.ToDynamic] __shim_key_to_string(key : K) -> String {
  match @gprelude.ToDynamic::to_dynamic(key) {
    @gprelude.DynString(s) => s
    @gprelude.DynInt(i) => i.to_string()
    @gprelude.DynFloat(f) => f.to_string()
    other => "<" + @gleam_stdlib_ffi.dynamic_classify(other) + ">"
  }
}

///|
fn __shim_decode_string(
  data : @gprelude.Dynamic,
) -> (String, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynString(s) => (s, @gprelude.Nil)
    _ => ("", decode_error("String", data))
  }
}

///|
fn __shim_decode_bool(
  data : @gprelude.Dynamic,
) -> (Bool, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynBool(b) => (b, @gprelude.Nil)
    _ => (false, decode_error("Bool", data))
  }
}

///|
fn __shim_decode_int(
  data : @gprelude.Dynamic,
) -> (Int64, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynInt(i) => (i, @gprelude.Nil)
    _ => (0L, decode_error("Int", data))
  }
}

///|
fn __shim_decode_float(
  data : @gprelude.Dynamic,
) -> (Double, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynFloat(f) => (f, @gprelude.Nil)
    _ => (0.0, decode_error("Float", data))
  }
}

///|
fn __shim_decode_bit_array(
  data : @gprelude.Dynamic,
) -> (@gprelude.BitArray, @gprelude.GList[DecodeError]) {
  match data {
    @gprelude.DynBitArray(ba) => (ba, @gprelude.Nil)
    _ => (@gprelude.BitArray::empty(), decode_error("BitArray", data))
  }
}

///|
fn[A] __shim_list(inner : Decoder[A]) -> Decoder[@gprelude.GList[A]] {
  Decoder(function=fn(data) {
    match @gleam_stdlib_ffi.decode_list_elements(data) {
      Err(_) => (@gprelude.Nil, decode_error("List", data))
      Ok(elements) =>
        for cur = elements, idx = 0L, acc = @gprelude.Nil {
          match cur {
            @gprelude.Nil => break (__shim_reverse_glist(acc), @gprelude.Nil)
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
fn[K, V] __shim_decode_dict(
  data : @gprelude.Dynamic,
  decode_entry : (
    @gleam_stdlib_ffi.Dict[K, V],
    @gprelude.Dynamic,
    @gprelude.Dynamic,
  ) -> (@gleam_stdlib_ffi.Dict[K, V], @gprelude.GList[DecodeError]),
) -> (@gleam_stdlib_ffi.Dict[K, V], @gprelude.GList[DecodeError]) {
  match @gleam_stdlib_ffi.decode_dict(data) {
    Err(_) => (@gleam_stdlib_ffi.dict_new(), decode_error("Dict", data))
    Ok(raw_dict) =>
      @gleam_stdlib_ffi.dict_fold(
        raw_dict,
        (@gleam_stdlib_ffi.dict_new(), @gprelude.Nil),
        fn(acc, k, v) {
          match acc.1 {
            @gprelude.Nil => decode_entry(acc.0, k, v)
            _ => acc
          }
        },
      )
  }
}
