public func zurry<A>(_ f: () -> A) -> A {
  return f()
}

public func unzurry<A>(_ a: A) -> () -> A {
  return { a }
}
