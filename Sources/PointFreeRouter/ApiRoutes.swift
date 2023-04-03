import Models
import URLRouting

extension SiteRoute {
  public enum Api: Equatable {
    case episodes
    case episode(Episode.ID)
  }
}

struct APIRouter: ParserPrinter {
  var body: some Router<SiteRoute.Api> {
    Path { "episodes" }

    OneOf {
      Route(.case(SiteRoute.Api.episodes))

      Route(.case(SiteRoute.Api.episode)) {
        Path { Digits().map(.representing(Episode.ID.self)) }
      }
    }
  }
}
