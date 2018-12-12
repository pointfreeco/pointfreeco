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

run(siteMiddleware, on: Current.envVars.port, gzip: true, baseUrl: Current.envVars.baseUrl)
