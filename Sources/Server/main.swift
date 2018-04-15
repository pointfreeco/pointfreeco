import Foundation
import HttpPipeline
import Optics
import PointFree
import Prelude

// EnvVars

let envFilePath = URL(fileURLWithPath: #file)
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .appendingPathComponent(".env")

let decoder = JSONDecoder()
let encoder = JSONEncoder()

let defaultEnvVarDict = (try? encoder.encode(AppEnvironment.current.envVars))
  .flatMap { try? decoder.decode([String: String].self, from: $0) }
  ?? [:]

let localEnvVarDict = (try? Data(contentsOf: envFilePath))
  .flatMap { try? decoder.decode([String: String].self, from: $0) }
  ?? [:]

let envVarDict = defaultEnvVarDict
  .merging(localEnvVarDict, uniquingKeysWith: { $1 })
  .merging(ProcessInfo.processInfo.environment, uniquingKeysWith: { $1 })

let envVars = (try? JSONSerialization.data(withJSONObject: envVarDict))
  .flatMap { try? decoder.decode(EnvVars.self, from: $0) }
  ?? AppEnvironment.current.envVars

AppEnvironment.push(\.envVars .~ envVars)

// Transcripts

#if OSS
private let allEpisodes = allPublicEpisodes
#else
private let allEpisodes = allPublicEpisodes + allPrivateEpisodes
#endif
AppEnvironment.push(\
  .episodes .~ {
    let now = AppEnvironment.current.date()
    return allEpisodes
      .filter {
        AppEnvironment.current.envVars.appEnv == .production
          ? $0.publishedAt <= now
          : true
    }
  }
)

// Bootstrap

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

// Server

run(siteMiddleware, on: AppEnvironment.current.envVars.port, gzip: true)
