import Prelude
import Tuple

public func tuple5<A, B, C, D, E>(_ a: A) -> (B) -> (C) -> (D) -> (E) -> (A, B, C, D, E) {
  return { b in { c in { d in { e in (a, b, c, d, e) } } } }
}

public func tuple6<A, B, C, D, E, F>(_ a: A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (A, B, C, D, E, F) {
  return { b in { c in { d in { e in { f in (a, b, c, d, e, f) } } } } }
}

public func tuple7<A, B, C, D, E, F, G>(_ a: A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (A, B, C, D, E, F, G) {
  return { b in { c in { d in { e in { f in { g in (a, b, c, d, e, f, g) } } } } } }
}

public func tuple8<A, B, C, D, E, F, G, H>(_ a: A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> (A, B, C, D, E, F, G, H) {
  return { b in { c in { d in { e in { f in { g in { h in (a, b, c, d, e, f, g, h) } } } } } } }
}

public func tuple9<A, B, C, D, E, F, G, H, I>(_ a: A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> (I) -> (A, B, C, D, E, F, G, H, I) {
  return { b in { c in { d in { e in { f in { g in { h in { i in (a, b, c, d, e, f, g, h, i) } } } } } } } }
}

public typealias T8<A, B, C, D, E, F, G, Z> = Tuple<A, T7<B, C, D, E, F, G, Z>>

public typealias Tuple7<A, B, C, D, E, F, G> = T8<A, B, C, D, E, F, G, Prelude.Unit>

public func get7<A, B, C, D, E, F, G, Z>(_ t: T8<A, B, C, D, E, F, G, Z>) -> G {
  return t.second.second.second.second.second.second.first
}

public func lower<A, B, C, D, E, F, G>(_ tuple: Tuple7<A, B, C, D, E, F, G>) -> (A, B, C, D, E, F, G) {
  return (get1(tuple), get2(tuple), get3(tuple), get4(tuple), get5(tuple), get6(tuple), get7(tuple))
}

public func require4<A, B, C, D, Z>(_ x: T5<A, B, C, D?, Z>) -> T5<A, B, C, D, Z>? {
  return get4(x).map { over4(const($0)) <| x }
}

public func require5<A, B, C, D, E, Z>(_ x: T6<A, B, C, D, E?, Z>) -> T6<A, B, C, D, E, Z>? {
  return get5(x).map { over5(const($0)) <| x }
}

public func require6<A, B, C, D, E, F, Z>(_ x: T7<A, B, C, D, E, F?, Z>) -> T7<A, B, C, D, E, F, Z>? {
  return get6(x).map { over6(const($0)) <| x }
}

public func sequence1<A, Z>(_ t: T2<IO<A>, Z>) -> IO<T2<A, Z>> {
  return IO {
    return t |> over1(perform)
  }
}

public func sequence2<A, B, Z>(_ t: T3<A, IO<B>, Z>) -> IO<T3<A, B, Z>> {
  return IO {
    return t |> over2(perform)
  }
}

public func sequence3<A, B, C, Z>(_ t: T4<A, B, IO<C>, Z>) -> IO<T4<A, B, C, Z>> {
  return IO {
    return t |> over3(perform)
  }
}

public func sequence4<A, B, C, D, Z>(_ t: T5<A, B, C, IO<D>, Z>) -> IO<T5<A, B, C, D, Z>> {
  return IO {
    return t |> over4(perform)
  }
}

public func sequence5<A, B, C, D, E, Z>(_ t: T6<A, B, C, D, IO<E>, Z>) -> IO<T6<A, B, C, D, E, Z>> {
  return IO {
    return t |> over5(perform)
  }
}

public func sequence6<A, B, C, D, E, F, Z>(_ t: T7<A, B, C, D, E, IO<F>, Z>) -> IO<T7<A, B, C, D, E, F, Z>> {
  return IO {
    return t |> over6(perform)
  }
}
