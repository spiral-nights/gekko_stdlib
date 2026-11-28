///|
pub fn bit_array_read_bits(arg0 : @gprelude.BitArray, arg1 : Int64, arg2 : Int64) -> @gprelude.BitArray? {
  @gprelude.bit_array_read_bits(arg0, arg1, arg2)
}

///|
pub fn bit_array_read_int(arg0 : @gprelude.BitArray, arg1 : Int64, arg2 : Int64, arg3 : Bool, arg4 : Bool) -> Int64? {
  @gprelude.bit_array_read_int(arg0, arg1, arg2, arg3, arg4)
}

///|
pub fn[T : @gprelude.GleamInspect] gleam_inspect(x : T) -> StringView {
  @gprelude.gleam_inspect(x)
}

///|
pub fn[T : @gprelude.ToDynamic] to_dynamic(x : T) -> @gprelude.Dynamic {
  @gprelude.to_dynamic(x)
}

///|
pub fn bit_size(self_ : @gprelude.BitArray) -> Int64 {
  @gprelude.BitArray::bit_size(self_)
}

///|
pub fn byte_size(self_ : @gprelude.BitArray) -> Int64 {
  @gprelude.BitArray::byte_size(self_)
}

///|
pub fn concat(arg0 : @gprelude.GList[@gprelude.BitArray]) -> @gprelude.BitArray {
  @gprelude.BitArray::concat((arg0).to_array()[:])
}

///|
pub fn from_string(arg0 : StringView) -> @gprelude.BitArray {
  @gprelude.BitArray::from_string(arg0)
}

///|
pub fn pad_to_bytes(self_ : @gprelude.BitArray) -> @gprelude.BitArray {
  @gprelude.BitArray::pad_to_bytes(self_)
}

///|
pub fn dynamic_dyn_null() -> @gprelude.Dynamic {
  @gprelude.DynNull
}

///|
pub fn dynamic_dyn_bool(arg0 : Bool) -> @gprelude.Dynamic {
  @gprelude.DynBool(arg0)
}

///|
pub fn dynamic_dyn_int(arg0 : Int64) -> @gprelude.Dynamic {
  @gprelude.DynInt(arg0)
}

///|
pub fn dynamic_dyn_float(arg0 : Double) -> @gprelude.Dynamic {
  @gprelude.DynFloat(arg0)
}

///|
pub fn dynamic_dyn_string(arg0 : StringView) -> @gprelude.Dynamic {
  @gprelude.DynString(arg0)
}

///|
pub fn dynamic_dyn_bit_array(arg0 : @gprelude.BitArray) -> @gprelude.Dynamic {
  @gprelude.DynBitArray(arg0)
}

///|
pub fn dynamic_dyn_list(arg0 : @gprelude.GList[@gprelude.Dynamic]) -> @gprelude.Dynamic {
  @gprelude.DynList(arg0)
}

///|
pub fn dynamic_dyn_array(arg0 : @gprelude.GList[@gprelude.Dynamic]) -> @gprelude.Dynamic {
  @gprelude.DynArray((arg0).to_array())
}

///|
pub fn dynamic_dyn_map(arg0 : Map[@gprelude.Dynamic, @gprelude.Dynamic]) -> @gprelude.Dynamic {
  @gprelude.DynMap(arg0)
}

///|
pub fn[Ret] match_dynamic(value : @gprelude.Dynamic, on_dyn_null : () -> Ret, on_dyn_bool : (Bool) -> Ret, on_dyn_int : (Int64) -> Ret, on_dyn_float : (Double) -> Ret, on_dyn_string : (StringView) -> Ret, on_dyn_bit_array : (@gprelude.BitArray) -> Ret, on_dyn_list : (@gprelude.GList[@gprelude.Dynamic]) -> Ret, on_dyn_array : (@gprelude.GList[@gprelude.Dynamic]) -> Ret, on_dyn_map : (Map[@gprelude.Dynamic, @gprelude.Dynamic]) -> Ret) -> Ret {
  match value {
    @gprelude.DynNull => on_dyn_null()
    @gprelude.DynBool(v0) => on_dyn_bool(v0)
    @gprelude.DynInt(v0) => on_dyn_int(v0)
    @gprelude.DynFloat(v0) => on_dyn_float(v0)
    @gprelude.DynString(v0) => on_dyn_string(v0)
    @gprelude.DynBitArray(v0) => on_dyn_bit_array(v0)
    @gprelude.DynList(v0) => on_dyn_list(v0)
    @gprelude.DynArray(v0) => on_dyn_array(@gprelude.GList::from_array((v0)[:]))
    @gprelude.DynMap(v0) => on_dyn_map(v0)
  }
}
