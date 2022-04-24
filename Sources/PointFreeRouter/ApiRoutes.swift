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
    Route(.case(SiteRoute.Api.episodes))

    Route(.case(SiteRoute.Api.episode)) {
      Path { Digits().map(.representing(Episode.Id.self)) }
    }
  }
}
