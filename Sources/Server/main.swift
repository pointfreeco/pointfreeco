import Dependencies
import HttpPipeline
import NIO
import PointFree
import Prelude

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
  on: DependencyValues._current.envVars.port,
  eventLoopGroup: DependencyValues._current.mainEventLoopGroup,
  gzip: true,
  baseUrl: DependencyValues._current.envVars.baseUrl
)
