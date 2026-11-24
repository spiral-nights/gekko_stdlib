///|
pub fn classify(data : @gprelude.Dynamic) -> String {
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
pub fn bool(a : Bool) -> @gprelude.Dynamic {
  @gprelude.DynBool(a)
}

///|
pub fn string(a : String) -> @gprelude.Dynamic {
  @gprelude.DynString(a)
}

///|
pub fn float(a : Double) -> @gprelude.Dynamic {
  @gprelude.DynFloat(a)
}

///|
pub fn int(a : Int64) -> @gprelude.Dynamic {
  @gprelude.DynInt(a)
}

///|
pub fn bit_array(a : @gprelude.BitArray) -> @gprelude.Dynamic {
  @gprelude.DynBitArray(a)
}

///|
pub fn list(a : @gprelude.GList[@gprelude.Dynamic]) -> @gprelude.Dynamic {
  @gprelude.DynList(a)
}

///|
pub fn array(a : @gprelude.GList[@gprelude.Dynamic]) -> @gprelude.Dynamic {
  @gprelude.DynArray(a.to_array())
}

///|
pub fn properties(
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
pub fn nil() -> @gprelude.Dynamic {
  @gprelude.DynNull
}
