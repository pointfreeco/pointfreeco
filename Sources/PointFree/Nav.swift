import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Styleguide
import Prelude

struct CurrentUser<A> {
  let continuation: A
  let user: User?
}

private func extractedGitHubUserEnvelope<I, A>(from conn: Conn<I, A>) -> GitHubUserEnvelope? {
  return conn.request.cookies[githubSessionCookieName]
    .flatMap {
      ResponseHeader.verifiedValue(
        signedCookieValue: $0,
        secret: AppEnvironment.current.envVars.appSecret
      )
  }
}

/// Fetches the current user from the DB based on what is stored in the encr
func fetchCurrentUser<A, I>(
  _ conn: Conn<I, A>
  ) -> IO<Conn<I, CurrentUser<A>>> {

  let currentUser = extractedGitHubUserEnvelope(from: conn).map {
    AppEnvironment.current.fetchUser($0.accessToken)
      .run
      .map(get(\.right) >>> flatMap(id))
      .map { CurrentUser(continuation: conn.data, user: $0) }
    }
    ?? pure(CurrentUser(continuation: conn.data, user: nil))

  return currentUser.map { conn.map(const($0)) }
}

let navView = View<User?> { _ in
  [
    nav([`class`([Class.pf.navBar])], [
      ul([`class`([Class.type.list.reset, Class.margin.all(0)])], [
        li([`class`([Class.layout.inline])], [
          a([href(path(to: .episodes(tag: nil))), `class`([Class.padding.leftRight(1)])], ["Videos"])
          ]),
        li([`class`([Class.layout.inline])], [
          a([href("#"), `class`([Class.padding.leftRight(1)])], ["Blog"])
          ]),
        li([`class`([Class.layout.inline])], [
          a([href("#"), `class`([Class.padding.leftRight(1)])], ["Books"])
          ]),
        li([`class`([Class.layout.inline])], [
          a([href(path(to: .about)), `class`([Class.padding.leftRight(1)])], ["About"])
          ]),
        ])
      ])
  ]
}

private let unpersonalizedNavItems = View<Prelude.Unit> { _ in
  [
    li([`class`([Class.layout.inline])], [
      a([href(path(to: .episodes(tag: nil))), `class`([Class.padding.leftRight(1)])], ["Videos"])
      ]),
    li([`class`([Class.layout.inline])], [
      a([href("#"), `class`([Class.padding.leftRight(1)])], ["Blog"])
      ]),
    li([`class`([Class.layout.inline])], [
      a([href("#"), `class`([Class.padding.leftRight(1)])], ["Books"])
      ]),
    li([`class`([Class.layout.inline])], [
      a([href(path(to: .about)), `class`([Class.padding.leftRight(1)])], ["About"])
      ]),
  ]
}

//let tmp = episodeTagView.view
//  >>> li([`class`([Class.layout.inlineBlock, Class.margin.right(1), Class.margin.bottom(1)])])

private let personalizedNavItems =
  loggedInNavItems
    <> loggedOutNavItems.contramap(const(unit))

private let loggedInNavItems = View<User?> { user in
  user.map { user in
    [
      a([href("#"), `class`([Class.padding.leftRight(1)])], ["Account"])
    ]
    }
    ?? []
}

private let loggedOutNavItems = View<Prelude.Unit> { _ in
  [
    a([href(path(to: .login(redirect: nil))), `class`([Class.padding.leftRight(1)])], ["Login"]),
    a([href(path(to: .pricing(unit))), `class`([Class.padding.leftRight(1)])], ["Subscribe"]),
  ]
}
