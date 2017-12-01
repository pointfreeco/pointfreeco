import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Optics
import Styleguide
import Prelude

struct RequestContext<A> {
  private(set) var data: A
  private(set) var currentUser: User? = nil
  private(set) var currentRequest: URLRequest

  func map<B>(_ f: (A) -> B) -> RequestContext<B> {
    return .init(
      data: f(self.data),
      currentUser: self.currentUser,
      currentRequest: self.currentRequest
    )
  }
}

func map<A, B>(_ f: @escaping (A) -> B) -> (RequestContext<A>) -> RequestContext<B> {
  return { $0.map(f) }
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

func setupGlobals<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<StatusLineOpen, RequestContext<A>>> {

  return pure(
    conn.map(
      const(
        RequestContext(
          data: conn.data,
          currentUser: nil,
          currentRequest: conn.request
        )
      )
    )
  )
  >>- _fetch(currentUser: \.currentUser)
}

func _fetch<A, I>(currentUser keyPath: WritableKeyPath<A, User?>) -> Middleware<I, I, A, A> {

  return { conn in
    let currentUser = extractedGitHubUserEnvelope(from: conn)
      .map {
        AppEnvironment.current.fetchUser($0.accessToken)
          .run
          .map(get(\.right) >>> flatMap(id))
      }
      ?? pure(nil)

    return (currentUser.map(set(keyPath)) <*> pure(conn.data))
      .map { conn.map(const($0)) }
  }
}

let navView = View<RequestContext<Prelude.Unit>> { globals in
  [
    gridRow([`class`([Class.pf.navBar, Class.grid.between(.xs), Class.pf.colors.bg.light]), style(height(.px(64)))], [
      gridColumn(
        sizes: [:],
        [`class`([Class.grid.col(.xs, nil)])],
        unpersonalizedNavItems.view(unit)
      ),

      gridColumn(
        sizes: [:],
        [`class`([Class.grid.col(.xs, nil)])],
        personalizedNavItems.view(globals)
      ),

      ]),
  ]
}

private let unpersonalizedNavItems = View<Prelude.Unit> { _ in
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
}

private let personalizedNavItems = View<RequestContext<Prelude.Unit>> { globals in
  globals.currentUser.map(loggedInNavItems.view)
    ?? loggedOutNavItems.view(globals.currentRequest)
}

private let loggedInNavItems = View<User> { user in

  ul([`class`([Class.layout.right, Class.type.list.reset, Class.margin.all(0)])], [
    li([`class`([Class.layout.inline])], [
      a([href("#"), `class`([Class.padding.leftRight(1)])], ["Account"])
      ]),

    li([`class`([Class.layout.inline])], [
      a([href(path(to: .logout)), `class`([Class.padding.leftRight(1)])], ["Logout"])
      ]),
    ])
}

private let loggedOutNavItems = View<URLRequest> { request in

  ul([`class`([Class.layout.right, Class.type.list.reset, Class.margin.all(0)])], [
    li([`class`([Class.layout.inline])], [
      a([href(path(to: .login(redirect: request.url?.absoluteString))), `class`([Class.padding.leftRight(1)])], ["Login"])
      ]),
    li([`class`([Class.layout.inline])], [
      a([href(path(to: .pricing(unit))), `class`([Class.padding.leftRight(1)])], ["Subscribe"])
      ]),
    ])
}
