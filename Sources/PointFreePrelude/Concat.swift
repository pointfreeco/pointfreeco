import Prelude

extension Monoid {
  public static func concat(_ xs: Self...) -> Self {
    return xs.reduce(.empty, <>)
  }
}

public func concat<A>(_ fs: [(A) -> A]) -> (A) -> A {
  return { a in
    fs.reduce(a) { a, f in f(a) }
  }
}

public func concat<A>(_ fs: ((A) -> A)..., and fz: @escaping (A) -> A = { $0 }) -> (A) -> A {
  return concat(fs + [fz])
}

public func concat<A>(_ fs: [(inout A) -> Void]) -> (inout A) -> Void {
  return { a in
    fs.forEach { f in f(&a) }
  }
}

public func concat<A>(_ fs: ((inout A) -> Void)..., and fz: @escaping (inout A) -> Void = { _ in })
  -> (inout A) -> Void {

    return concat(fs + [fz])
}

public func update<A>(_ value: inout A, _ changes: ((A) -> A)...) {
  value = concat(changes)(value)
}

public func update<A>(_ value: inout A, _ changes: ((inout A) -> Void)...) {
  concat(changes)(&value)
}
