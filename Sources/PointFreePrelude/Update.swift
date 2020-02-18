public func update<A>(_ value: A, _ mutations: (inout A) -> Void...) -> A {
  var value = value
  mutations.forEach { $0(&value) }
  return value
}
