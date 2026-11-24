///|
pub fn dynamic_classify(data : @gprelude.Dynamic) -> String {
  match data {
    @gprelude.DynNull => "Nil"
    @gprelude.DynBool(_) => "Bool"
    @gprelude.DynInt(_) => "Int"
    @gprelude.DynFloat(_) => "Float"
    @gprelude.DynString(_) => "String"
    @gprelude.DynBitArray(_) => "BitArray"
    @gprelude.DynList(_) => "List"
    @gprelude.DynArray(_) => "Array"
    @gprelude.DynMap(_) => "Dict"
  }
}

///|
pub fn dynamic_bool(a : Bool) -> @gprelude.Dynamic {
  @gprelude.DynBool(a)
}

///|
pub fn dynamic_string(a : String) -> @gprelude.Dynamic {
  @gprelude.DynString(a)
}

///|
pub fn dynamic_float(a : Double) -> @gprelude.Dynamic {
  @gprelude.DynFloat(a)
}

///|
pub fn dynamic_int(a : Int64) -> @gprelude.Dynamic {
  @gprelude.DynInt(a)
}

///|
pub fn dynamic_bit_array(a : @gprelude.BitArray) -> @gprelude.Dynamic {
  @gprelude.DynBitArray(a)
}

///|
pub fn dynamic_list(
  a : @gprelude.GList[@gprelude.Dynamic],
) -> @gprelude.Dynamic {
  @gprelude.DynList(a)
}

///|
pub fn dynamic_array(
  a : @gprelude.GList[@gprelude.Dynamic],
) -> @gprelude.Dynamic {
  @gprelude.DynArray(a.to_array())
}

///|
pub fn dynamic_properties(
  entries : @gprelude.GList[(@gprelude.Dynamic, @gprelude.Dynamic)],
) -> @gprelude.Dynamic {
  let m : Map[@gprelude.Dynamic, @gprelude.Dynamic] = Default::default()
  for cur = entries {
    match cur {
      @gprelude.Nil => break @gprelude.DynMap(m)
      @gprelude.Cons((k, v), rest) => {
        m.set(k, v)
        continue rest
      }
    }
  }
}

///|
pub fn dynamic_nil() -> @gprelude.Dynamic {
  @gprelude.DynNull
}

///|
pub fn[K : @gprelude.ToDynamic] decode_bare_index(
  data : @gprelude.Dynamic,
  key : K,
) -> Result[@gprelude.Dynamic?, String] {
  let dk = @gprelude.ToDynamic::to_dynamic(key)
  match (data, dk) {
    (@gprelude.DynMap(m), _) => Ok(m.get(dk))
    (@gprelude.DynArray(arr), @gprelude.DynInt(idx)) =>
      if idx >= 0L && idx.to_int() < arr.length() {
        Ok(Some(arr[idx.to_int()]))
      } else {
        Ok(None)
      }
    (@gprelude.DynList(xs), @gprelude.DynInt(idx)) => {
      if idx < 0L {
        return Ok(None)
      }
      for cur = xs, i = 0L {
        match cur {
          @gprelude.Nil => break Ok(None)
          @gprelude.Cons(v, rest) =>
            if i == idx {
              break Ok(Some(v))
            } else {
              continue rest, i + 1L
            }
        }
      }
    }
    (@gprelude.DynArray(_), _) | (@gprelude.DynList(_), _) => Ok(None)
    (_, @gprelude.DynInt(_)) => Err("Indexable")
    _ => Err("Dict")
  }
}

///|
pub fn decode_dynamic_string(data : @gprelude.Dynamic) -> Result[String, String] {
  match data {
    @gprelude.DynString(s) => Ok(s)
    _ => Err("")
  }
}

///|
pub fn decode_dynamic_int(data : @gprelude.Dynamic) -> Result[Int64, Int64] {
  match data {
    @gprelude.DynInt(i) => Ok(i)
    _ => Err(0L)
  }
}

///|
pub fn decode_dynamic_float(
  data : @gprelude.Dynamic,
) -> Result[Double, Double] {
  match data {
    @gprelude.DynFloat(f) => Ok(f)
    _ => Err(0.0)
  }
}

///|
pub fn decode_dynamic_bit_array(
  data : @gprelude.Dynamic,
) -> Result[@gprelude.BitArray, @gprelude.BitArray] {
  match data {
    @gprelude.DynBitArray(ba) => Ok(ba)
    _ => Err(@gprelude.BitArray::empty())
  }
}

///|
pub fn decode_list_elements(
  data : @gprelude.Dynamic,
) -> Result[@gprelude.GList[@gprelude.Dynamic], Unit] {
  match data {
    @gprelude.DynList(xs) => Ok(xs)
    @gprelude.DynArray(arr) => Ok(@gprelude.GList::from_array(arr[:]))
    _ => Err(())
  }
}

///|
pub fn decode_dict(
  data : @gprelude.Dynamic,
) -> Result[Dict[@gprelude.Dynamic, @gprelude.Dynamic], Unit] {
  match data {
    @gprelude.DynMap(m) => Ok({ inner: m })
    _ => Err(())
  }
}

///|
pub fn[T : @gprelude.ToDynamic] decode_cast(a : T) -> @gprelude.Dynamic {
  @gprelude.ToDynamic::to_dynamic(a)
}

///|
pub fn decode_is_null(a : @gprelude.Dynamic) -> Bool {
  match a {
    @gprelude.DynNull => true
    _ => false
  }
}
