///|
pub fn[K : Eq + Hash, V] contains(self_ : @moonbitlang_core_immut_hashmap.HashMap[K, V], arg1 : K) -> Bool {
  @moonbitlang_core_immut_hashmap.HashMap::contains(self_, arg1)
}

///|
pub fn[K, V] empty() -> @moonbitlang_core_immut_hashmap.HashMap[K, V] {
  @moonbitlang_core_immut_hashmap.HashMap::empty()
}

///|
pub fn[K, V] filter(self_ : @moonbitlang_core_immut_hashmap.HashMap[K, V], arg1 : (K, V) -> Bool) -> @moonbitlang_core_immut_hashmap.HashMap[K, V] {
  @moonbitlang_core_immut_hashmap.HashMap::filter(self_, arg1)
}

///|
pub fn[K, V, A] fold(self_ : @moonbitlang_core_immut_hashmap.HashMap[K, V], init_ : A, arg2 : (A, K, V) -> A) -> A {
  @moonbitlang_core_immut_hashmap.HashMap::fold(self_, init=init_, arg2)
}

///|
pub fn[K : Eq + Hash, V] get(self_ : @moonbitlang_core_immut_hashmap.HashMap[K, V], arg1 : K) -> V? {
  @moonbitlang_core_immut_hashmap.HashMap::get(self_, arg1)
}

///|
pub fn[K : Eq + Hash, V] insert(self_ : @moonbitlang_core_immut_hashmap.HashMap[K, V], arg1 : K, arg2 : V) -> @moonbitlang_core_immut_hashmap.HashMap[K, V] {
  @moonbitlang_core_immut_hashmap.HashMap::insert(self_, arg1, arg2)
}

///|
pub fn[K, V] length(self_ : @moonbitlang_core_immut_hashmap.HashMap[K, V]) -> Int64 {
  (@moonbitlang_core_immut_hashmap.HashMap::length(self_)).to_int64()
}

///|
pub fn[K, V, A] map(self_ : @moonbitlang_core_immut_hashmap.HashMap[K, V], arg1 : (K, V) -> A) -> @moonbitlang_core_immut_hashmap.HashMap[K, A] {
  @moonbitlang_core_immut_hashmap.HashMap::map(self_, arg1)
}

///|
pub fn[K : Eq + Hash, V] remove(self_ : @moonbitlang_core_immut_hashmap.HashMap[K, V], arg1 : K) -> @moonbitlang_core_immut_hashmap.HashMap[K, V] {
  @moonbitlang_core_immut_hashmap.HashMap::remove(self_, arg1)
}
