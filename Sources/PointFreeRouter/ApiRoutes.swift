import ApplicativeRouter
import Parsing
import Prelude
import Models
import _URLRouting

extension AppRoute {
  public enum Api: Equatable {
    case episodes
    case episode(Episode.Id)
  }
}

let apiRouter = Parse {
  Path { "episodes" }

  OneOf {
    Route(/AppRoute.Api.episodes)

    Route(/AppRoute.Api.episode) {
      Path { Int.parser().map(.representing(Episode.Id.self)) }
    }
  }
}
