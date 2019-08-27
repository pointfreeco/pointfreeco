import ApplicativeRouter
import Prelude
import Models

extension Route {
  public enum Api: DerivePartialIsos, Equatable {
    case episodes
    case episode(Episode.Id)
  }
}

let apiRouter
  = apiRouters.reduce(.empty, <|>)

private let apiRouters: [Router<Route.Api>] = [
  .episodes
    <¢> "episodes" <% end,

  .episode
    <¢> "episodes" %> pathParam(.tagged(.int)) <% end
]
