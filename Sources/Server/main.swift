import HttpPipeline
import PointFree
import Prelude

// Bootstrap

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

// Server

run(
  siteMiddleware,
  on: Current.envVars.port,
  eventLoopGroup: Current.eventLoopGroup,
  gzip: true,
  baseUrl: Current.envVars.baseUrl
)
