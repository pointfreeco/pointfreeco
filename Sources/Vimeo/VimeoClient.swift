import Dependencies
import DependenciesMacros

@DependencyClient
public struct VimeoClient {
  public var video: (_ id: Video.ID) async throws -> Video
  public var videos: (_ page: Int?, _ perPage: Int?) async throws -> VideosEnvelope
}

extension VimeoClient: TestDependencyKey {
  public static let testValue = VimeoClient()
}

extension DependencyValues {
  public var vimeoClient: VimeoClient {
    get { self[VimeoClient.self] }
    set { self[VimeoClient.self] = newValue }
  }
}
