import Dependencies
import Foundation
import HttpPipeline
import NIO
import PointFree
import Prelude

@main
struct Server {
  static func main() async throws {
    @Dependency(\.envVars) var envVars
    @Dependency(\.mainEventLoopGroup) var eventLoopGroup: any EventLoopGroup

    // Bootstrap
    _ =
      try await PointFree
      .bootstrap()
      .run
      .performAsync()
      .unwrap()

    // Server
    run(
      siteMiddleware,
      on: envVars.port,
      eventLoopGroup: eventLoopGroup,
      gzip: true,
      baseUrl: envVars.baseUrl
    )
  }
}
