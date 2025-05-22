import Dependencies
import PointFree
import Vimeo

@main
struct VimeoCloudflareMigration {
  static func main() async throws {
    prepareDependencies {
      $0.vimeoClient = .live(
        bearer: $0.envVars.vimeo.bearer,
        userId: $0.envVars.vimeo.userId
      )
    }

    @Dependency(\.vimeoClient) var vimeo

    let videos = try await vimeo.videos(page: nil, perPage: 1)
    dump(videos)
  }
}
