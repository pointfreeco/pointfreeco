import Dependencies
import DependenciesMacros

@DependencyClient
public struct VimeoClient {
  public var video: (_ id: VimeoVideo.ID) async throws -> VimeoVideo
  public var videos: (_ inCollection: Int) async throws -> CollectionVideos

  public struct CollectionVideos: Decodable {
    public var data: [VimeoVideo]
    public init(data: [VimeoVideo]) {
      self.data = data
    }
  }
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
