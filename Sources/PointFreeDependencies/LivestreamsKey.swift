import Dependencies
import Models

private enum LivestreamsKey: DependencyKey {
  static let liveValue: [Livestream] = []
  static let testValue: [Livestream] = []
}

extension DependencyValues {
  public var livestreams: [Livestream] {
    get { self[LivestreamsKey.self] }
    set { self[LivestreamsKey.self] = newValue }
  }
}
