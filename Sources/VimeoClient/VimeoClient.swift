import Dependencies
import DependenciesMacros

@DependencyClient
public struct VimeoClient {
  public var video: (_ id: VimeoVideo.ID) async throws -> VimeoVideo
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
