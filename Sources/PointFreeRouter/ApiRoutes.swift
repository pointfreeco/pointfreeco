import ApplicativeRouter
import Parsing
import Prelude
import Models
import URLRouting

extension Route {
  public enum Api: Equatable {
    case episodes
    case episode(Episode.Id)
  }
}

let apiRouter = Parse {
  Path { "episodes" }

  OneOf {
    Routing(/Route.Api.episodes) {
      Method.get
    }
    
    Routing(/Route.Api.episode) {
      Method.get
      Path { Episode.Id.parser() }
    }
  }
}

/*
 let apiRouter
   = apiRouters.reduce(.empty, <|>)

 private let apiRouters: [Router<Route.Api>] = [
   .case(.episodes)
     <¢> "episodes" <% end,

   .case(Route.Api.episode)
     <¢> "episodes" %> pathParam(.tagged(.int)) <% end
 ]
 */
