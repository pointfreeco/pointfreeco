import Dependencies

public struct VimeoClient {
  public var video: (VimeoVideo.ID) async throws -> VimeoVideo
}

extension VimeoClient: TestDependencyKey {
  public static let testValue = VimeoClient(
    video: unimplemented("VimeoClient.video")
  )
}

extension DependencyValues {
  public var vimeoClient: VimeoClient {
    get { self[VimeoClient.self] }
    set { self[VimeoClient.self] = newValue }
  }
}
