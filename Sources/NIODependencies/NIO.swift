import Dependencies
import NIOCore
import NIOEmbedded

extension DependencyValues {
  public var mainEventLoopGroup: any EventLoopGroup {
    get { self[MainEventLoopGroupKey.self] }
    set { self[MainEventLoopGroupKey.self] = newValue }
  }
}

public enum MainEventLoopGroupKey: TestDependencyKey {
  public static var testValue: any EventLoopGroup {
    EmbeddedEventLoop()
  }
}
