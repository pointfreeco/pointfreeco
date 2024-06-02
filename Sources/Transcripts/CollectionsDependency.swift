import Dependencies
import DependenciesMacros
import Models

@DependencyClient
public struct CollectionsClient {
  public var all: () -> [Episode.Collection] = { [] }
  public var update: ([Episode.Collection]) async throws -> Void
}

extension CollectionsClient {
  public static var live: Self {
    let collections = LockIsolated(Episode.Collection.all)

    return Self(
      all: { collections.value },
      update: { newValue in collections.withValue { $0 = newValue } }
    )
  }
}

extension Episode.Collection: DependencyKey {
  public static let liveValue = CollectionsClient.live
  public static let testValue = CollectionsClient(all: { [.mock] }, update: { _ in })
}

extension DependencyValues {
  public var collections: CollectionsClient {
    get { self[Episode.Collection.self] }
    set { self[Episode.Collection.self] = newValue }
  }
}
