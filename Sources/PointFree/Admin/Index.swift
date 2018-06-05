import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

public let adminEmails: [EmailAddress] = [
  "mbw234@gmail.com",
  "stephen.celis@gmail.com"
]

func requireAdmin<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User?, A>, Data> {

    return filterMap(require1 >>> pure, or: loginAndRedirect)
      <<< filter(get1 >>> ^\.isAdmin, or: redirect(to: .home))
      <| middleware
}

let adminIndex =
  requireAdmin
    <| writeStatus(.ok)
    >=> respond(adminIndexView.contramap(lower))

private let adminIndexView = View<Database.User> { currentUser in
  ul([
    li([
      a([href(path(to: .admin(.newEpisodeEmail(.show))))], ["Send new episode email"]),
      ]),

    li([
      a([href(path(to: .admin(.episodeCredits(.show))))], ["Send episode credits"])
      ]),

    li([
      a([href(path(to: .admin(.freeEpisodeEmail(.index))))], ["Send free episode email"]),
      ]),

    li([
      a([href(path(to: .admin(.newBlogPostEmail(.index))))], ["Send new blog post email"]),
      ]),
    ])
}
