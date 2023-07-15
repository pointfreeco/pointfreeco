import Dependencies

private enum IsSpiPromoKey: DependencyKey {
  static let liveValue = false
  static let testValue = false
}

extension DependencyValues {
  public var isSpiPromo: Bool {
    get { self[IsSpiPromoKey.self] }
    set { self[IsSpiPromoKey.self] = newValue }
  }
}
