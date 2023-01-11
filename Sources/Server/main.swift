import Dependencies
import HttpPipeline
import NIO
import PointFree
import Prelude

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
      { conn in
        //        IO {
        await siteMiddleware(conn)

//      }
//        conn.writeStatus(.ok).respond(text: "Hi")
      },
      on: envVars.port,
      eventLoopGroup: eventLoopGroup,
      gzip: true,
      baseUrl: envVars.baseUrl
    )
  }
}

import Dispatch
let group = DispatchGroup()
group.enter()
Task {
  try await Server.main()
  group.leave()
}
group.wait()
