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
    prepareDependencies {
      $0[CloudflareClient.self] =
        .live(
          accountID: $0.envVars.cloudflare.accountID,
          apiToken: $0.envVars.cloudflare.streamAPIKey
        )
    }
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
