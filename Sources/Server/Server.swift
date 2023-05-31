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
    await PointFree.bootstrap()

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
