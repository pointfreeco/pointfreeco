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
  try! PointFree
  .bootstrap(eventLoopGroup: eventLoopGroup)
  .run
  .perform()
  .unwrap()

// Server

run(
  siteMiddleware,
  on: Current.envVars.port,
  eventLoopGroup: eventLoopGroup,
  gzip: true,
  baseUrl: Current.envVars.baseUrl
)
