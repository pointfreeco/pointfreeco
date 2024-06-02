import Database
import Dependencies
import DependenciesMacros
import Models

@DependencyClient
public struct CollectionsClient {
  public var all: () -> [Episode.Collection] = { [] }
  public var bootstrap:() async throws -> Void
}

extension CollectionsClient {
  public static var live: Self {
    let collections = LockIsolated(Episode.Collection.all)

    return Self(
      all: { collections.value },
      bootstrap: {
        @Dependency(\.database) var database

        var cs = collections.value
        defer {
          collections.withValue { [cs] in $0 = cs }
        }
        for (collectionIndex, var collection) in cs.enumerated() {
          defer { cs[collectionIndex] = collection }
          for (sectionIndex, var section) in collection.sections.enumerated() {
            defer { collection.sections[sectionIndex] = section }
            for (lessonIndex, var lesson) in section.coreLessons.enumerated() {
              defer { section.coreLessons[lessonIndex] = lesson }

              switch lesson {
              case .clip(let clip):
                do {
                  let clip = try await database.fetchClip(vimeoVideoID: clip.vimeoID)
                  lesson = .clip(clip)
                } catch {
                  // TODO: print error
                }
              case .episode:
                break
              }
            }
          }
        }
      }
    )
  }
}

extension Episode.Collection: DependencyKey {
  public static let liveValue = CollectionsClient.live
  public static let testValue = CollectionsClient(all: { [.mock] }, bootstrap: { })
}

extension DependencyValues {
  public var collections: CollectionsClient {
    get { self[Episode.Collection.self] }
    set { self[Episode.Collection.self] = newValue }
  }
}
