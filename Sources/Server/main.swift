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
  on: Current.envVars.port,
  eventLoopGroup: DependencyValues._current.mainEventLoopGroup,
  gzip: true,
  baseUrl: Current.envVars.baseUrl
)
