import ApplicativeRouter
import Parsing
import Prelude
import Models
import URLRouting

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
      Path { Episode.Id.parser(rawValue: Int.parser()) }
    }
  }
}
