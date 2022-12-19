import HttpPipeline
import NIO
import PointFree
import Prelude

// Bootstrap

#if DEBUG
  let numberOfThreads = 1
#else
  let numberOfThreads = System.coreCount
#endif
let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)

_ =
  try await PointFree
  .bootstrap(eventLoopGroup: eventLoopGroup)
  .run
  .performAsync()
  .unwrap()

// Server

run(
  siteMiddleware,
  on: Current.envVars.port,
  eventLoopGroup: eventLoopGroup,
  gzip: true,
  baseUrl: Current.envVars.baseUrl
)
