///|
pub(all) struct Dict[K, V] {
  inner : Map[K, V]
}

///|
pub(all) struct TransientDict[K, V] {
  inner : Map[K, V]
}

///|
pub impl[K : Eq + Hash, V : Eq] Eq for Dict[K, V] with equal(self, other) {
  self.inner == other.inner
}

///|
pub impl[K : Debug, V : Debug] Debug for Dict[K, V] with to_repr(self) {
  Debug::to_repr(self.inner)
}

///|
pub impl[K : @gprelude.GleamInspect, V : @gprelude.GleamInspect] @gprelude.GleamInspect for Dict[
  K,
  V,
] with gleam_inspect(self) {
  let buf = StringBuilder()
  buf.write_string("dict.from_list([")
  let mut first = true
  self.inner.each(fn(k, v) {
    if !first {
      buf.write_string(", ")
    }
    first = false
    buf.write_string("#(")
    buf.write_string(@gprelude.GleamInspect::gleam_inspect(k))
    buf.write_string(", ")
    buf.write_string(@gprelude.GleamInspect::gleam_inspect(v))
    buf.write_char(')')
  })
  buf.write_string("])")
  buf.to_string()
}

///|
pub impl[K : Hash, V : Hash] Hash for Dict[K, V] with hash_combine(self, hasher) {
  hasher.combine_int(self.inner.length())
  let mut acc_xor : UInt64 = 0UL
  let mut acc_sum : UInt64 = 0UL
  self.inner.each(fn(k, v) {
    let h = Hasher(seed=0)
    h.combine(k)
    h.combine(v)
    let x = h.finalize().reinterpret_as_uint().to_uint64()
    acc_xor = acc_xor ^ x
    acc_sum = acc_sum + x
  })
  hasher.combine_uint64(acc_xor)
  hasher.combine_uint64(acc_sum)
}

///|
pub fn[K, V] dict_to_transient(d : Dict[K, V]) -> TransientDict[K, V] {
  { inner: d.inner.copy() }
}

///|
pub fn[K, V] dict_from_transient(t : TransientDict[K, V]) -> Dict[K, V] {
  { inner: t.inner }
}

///|
pub fn[K, V] dict_size(d : Dict[K, V]) -> Int64 {
  d.inner.length().to_int64()
}

///|
pub fn[K : Eq + Hash, V] dict_has_key(d : Dict[K, V], key : K) -> Bool {
  d.inner.contains(key)
}

///|
pub fn[K, V] dict_new() -> Dict[K, V] {
  { inner: Default::default() }
}

///|
pub fn[K : Eq + Hash, V] dict_get(from : Dict[K, V], key : K) -> Result[V, Unit] {
  match from.inner.get(key) {
    Some(v) => Ok(v)
    None => Err(())
  }
}

///|
pub fn[K : Eq + Hash, V] dict_insert(
  d : Dict[K, V],
  key : K,
  val : V,
) -> Dict[K, V] {
  let m = d.inner.copy()
  m.set(key, val)
  { inner: m }
}

///|
pub fn[K : Eq + Hash, V] dict_transient_insert(
  key : K,
  val : V,
  transient : TransientDict[K, V],
) -> TransientDict[K, V] {
  transient.inner.set(key, val)
  transient
}

///|
pub fn[K : Eq + Hash, V, A] dict_map_values(
  d : Dict[K, V],
  fun : (K, V) -> A,
) -> Dict[K, A] {
  let m : Map[K, A] = Default::default()
  d.inner.each(fn(k, v) { m.set(k, fun(k, v)) })
  { inner: m }
}

///|
pub fn[K : Eq + Hash, V] dict_transient_delete(
  key : K,
  transient : TransientDict[K, V],
) -> TransientDict[K, V] {
  transient.inner.remove(key)
  transient
}

///|
pub fn[K, V, Acc] dict_fold(
  d : Dict[K, V],
  initial : Acc,
  fun : (Acc, K, V) -> Acc,
) -> Acc {
  let mut acc = initial
  d.inner.each(fn(k, v) { acc = fun(acc, k, v) })
  acc
}

///|
pub fn[K : Eq + Hash, V] dict_transient_update_with(
  key : K,
  fun : (V) -> V,
  init : V,
  transient : TransientDict[K, V],
) -> TransientDict[K, V] {
  match transient.inner.get(key) {
    Some(existing) => transient.inner.set(key, fun(existing))
    None => transient.inner.set(key, init)
  }
  transient
}
