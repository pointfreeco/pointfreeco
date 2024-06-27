import Dependencies

extension HTML {
  public func dependency<Value>(
    _ keyPath: WritableKeyPath<DependencyValues, Value>,
    _ value: Value
  ) -> some HTML {
    _DependencyKeyWritingModifier(base: self, keyPath: keyPath, value: value)
  }
}

private struct _DependencyKeyWritingModifier<Base: HTML, Value>: HTML {
  let base: Base
  let keyPath: WritableKeyPath<DependencyValues, Value>
  let value: Value

  static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    withDependencies {
      $0[keyPath: html.keyPath] = html.value
    } operation: {
      Base._render(html.base, into: &printer)
    }
  }
  var body: Never { fatalError() }
}
