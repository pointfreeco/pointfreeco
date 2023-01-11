import Dependencies
import HttpPipeline
import NIO
import PointFree
import Prelude
import Dispatch

// NB: this DispachGroup/Task is necessary to work around strange deadlock issues in Swift async.
//     For more info, see:
//     https://github.com/apple/swift-nio/blob/1ce136b4c392bd7427cf408d65305a05d162fb46/Sources/NIOAsyncAwaitDemo/main.swift#L66-L76.
let group = DispatchGroup()
group.enter()
Task {
  defer { group.leave() }

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
group.wait()
