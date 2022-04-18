import CasePaths
import Parsing
import Prelude
import Models
import _URLRouting

extension SiteRoute {
  public enum Api: Equatable {
    case episodes
    case episode(Episode.Id)
  }
}

let apiRouter = Parse {
  Path { "episodes" }

  OneOf {
    Route(/SiteRoute.Api.episodes)

    Route(/SiteRoute.Api.episode) {
      Path { Int.parser().map(.representing(Episode.Id.self)) }
    }
  }
}
