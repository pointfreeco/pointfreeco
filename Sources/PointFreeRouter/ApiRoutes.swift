import CasePaths
import Models
import URLRouting

extension SiteRoute {
  @CasePathable
  public enum Api: Equatable {
    case episodes
    case episode(Episode.ID)
  }
}

struct APIRouter: ParserPrinter {
  var body: some Router<SiteRoute.Api> {
    Path { "episodes" }

    OneOf(output: SiteRoute.Api.self) {
      Route(.case(\.episodes))

      Route(.case(\.episode)) {
        Path { Digits().map(.representing(Episode.ID.self)) }
      }
    }
  }
}
