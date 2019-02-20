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
