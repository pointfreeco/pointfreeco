import Cloudflare
import Dependencies
import Foundation
import HttpPipeline
import NIO
import PointFree
import Prelude

@main
struct Server {
  static func main() async throws {
    await PointFree.bootstrap()

    @Dependency(\.envVars) var envVars
    @Dependency(\.mainEventLoopGroup) var eventLoopGroup: any EventLoopGroup
    
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
