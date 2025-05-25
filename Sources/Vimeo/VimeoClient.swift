import Dependencies
import DependenciesMacros

@available(*, deprecated)
@DependencyClient
public struct VimeoClient {
  public var video: (_ id: Video.ID) async throws -> Video
  public var videos: (_ page: Int?, _ perPage: Int?) async throws -> VideosEnvelope
}

@available(*, deprecated)
extension VimeoClient: TestDependencyKey {
  public static let testValue = VimeoClient()
}

extension DependencyValues {
  @available(*, deprecated)
  public var vimeoClient: VimeoClient {
    get { self[VimeoClient.self] }
    set { self[VimeoClient.self] = newValue }
  }
}
