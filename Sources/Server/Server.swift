import Dependencies
import Foundation
import HttpPipeline
import NIO
import PointFree
import Prelude

#if canImport(AppKit)
  import AppKit
#endif

@main
struct Server {
  static func main() async throws {
    @Dependency(\.envVars) var envVars
    @Dependency(\.mainEventLoopGroup) var eventLoopGroup: any EventLoopGroup

    // Bootstrap
    await PointFree.bootstrap()

    #if canImport(AppKit)
      Task.detached {
        try await Task.sleep(for: .seconds(0.3))
        let url = URL(string: "http://localhost:8080")!
        _ = NSWorkspace.shared.open(url)
      }
    #endif

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
