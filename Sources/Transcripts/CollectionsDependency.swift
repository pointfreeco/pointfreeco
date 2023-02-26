import Dependencies
import Models

extension Episode.Collection: DependencyKey {
  public static let liveValue = Episode.Collection.all
  public static let testValue = [Episode.Collection.mock]
}

extension DependencyValues {
  public var collections: [Episode.Collection] {
    get { self[Episode.Collection.self] }
    set { self[Episode.Collection.self] = newValue }
  }
}
