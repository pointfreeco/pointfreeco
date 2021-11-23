import ApplicativeRouter
import Parsing
import Prelude
import Models

extension Route {
  public enum Api: Equatable {
    case episodes
    case episode(Episode.Id)
  }
}

let apiRouter
  = apiRouters.reduce(.empty, <|>)

private let apiRouters: [Router<Route.Api>] = [
  .case(.episodes)
    <¢> "episodes" <% end,

  .case(Route.Api.episode)
    <¢> "episodes" %> pathParam(.tagged(.int)) <% end
]

private let _apiRouter = Parse {
  Path("episodes")

  OneOf {
    Routing(/Route.Api.episodes) {
      Method.get
    }
    
    Routing(/Route.Api.episode) {
      Method.get
      Path(Int.parser().pipe { Episode.Id.parser() })
    }
  }
}
