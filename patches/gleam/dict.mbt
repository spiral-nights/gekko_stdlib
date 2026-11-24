///|
#gekko.patch
pub(all) struct Dict[K, V] {
  inner : Map[K, V]
}

///|
#gekko.patch
priv struct TransientDict[K, V] {
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
#gekko.patch
fn[K, V] to_transient(d : Dict[K, V]) -> TransientDict[K, V] {
  { inner: d.inner.copy() }
}

///|
#gekko.patch
fn[K, V] from_transient(t : TransientDict[K, V]) -> Dict[K, V] {
  { inner: t.inner }
}

///|
#gekko.patch
pub fn[K, V] size(d : Dict[K, V]) -> Int64 {
  d.inner.length().to_int64()
}

///|
#gekko.patch
pub fn[K : Eq + Hash, V] has_key(d : Dict[K, V], key : K) -> Bool {
  d.inner.contains(key)
}

///|
#gekko.patch
pub fn[K, V] new() -> Dict[K, V] {
  { inner: Default::default() }
}

///|
#gekko.patch
pub fn[K : Eq + Hash, V] get(from : Dict[K, V], key : K) -> Result[V, Unit] {
  match from.inner.get(key) {
    Some(v) => Ok(v)
    None => Err(())
  }
}

///|
#gekko.patch
fn[K : Eq + Hash, V] do_insert(
  key : K,
  val : V,
  d : Dict[K, V],
) -> Dict[K, V] {
  let m = d.inner.copy()
  m.set(key, val)
  { inner: m }
}

///|
#gekko.patch
fn[K : Eq + Hash, V] transient_insert(
  key : K,
  val : V,
  transient : TransientDict[K, V],
) -> TransientDict[K, V] {
  transient.inner.set(key, val)
  transient
}

///|
#gekko.patch
pub fn[K : Eq + Hash, V, A] map_values(
  d : Dict[K, V],
  fun : (K, V) -> A,
) -> Dict[K, A] {
  let m : Map[K, A] = Default::default()
  d.inner.each(fn(k, v) { m.set(k, fun(k, v)) })
  { inner: m }
}

///|
#gekko.patch
fn[K : Eq + Hash, V] transient_delete(
  key : K,
  transient : TransientDict[K, V],
) -> TransientDict[K, V] {
  transient.inner.remove(key)
  transient
}

///|
#gekko.patch
pub fn[K, V, Acc] fold(
  d : Dict[K, V],
  initial : Acc,
  fun : (Acc, K, V) -> Acc,
) -> Acc {
  let mut acc = initial
  d.inner.each(fn(k, v) { acc = fun(acc, k, v) })
  acc
}

///|
#gekko.patch
fn[K : Eq + Hash, V] transient_update_with(
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
