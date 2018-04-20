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

run(siteMiddleware, on: AppEnvironment.current.envVars.port, gzip: true)
