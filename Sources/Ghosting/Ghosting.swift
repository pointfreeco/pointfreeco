import Dependencies

extension DependencyValues {
  public var isGhosting: Bool {
    get { self[IsGhostingKey.self] }
    set { self[IsGhostingKey.self] = newValue }
  }
}

private enum IsGhostingKey: DependencyKey {
  static let liveValue = false
  static let testValue = false
}
