import Css
import CssReset
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide
import Tuple

//
//func _requestContextMiddleware<A>(
//  _ conn: Conn<StatusLineOpen, A>
//  ) -> IO<Conn<StatusLineOpen, Tuple3<Database.User?, URLRequest, A>>> {

func requireUser<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple3<Database.User, URLRequest, A>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

  return { conn in

    let currentUser = extractedGitHubUserEnvelope(from: conn.request)
      .map {
        AppEnvironment.current.database.fetchUserByGitHub($0.accessToken)
          .run
          .map(^\.right >>> flatMap(id))
      }
      ?? pure(nil)

    return currentUser.flatMap { user in
      user.map { conn.map(const($0 .*. conn.request .*. conn.data)) |> middleware }
      ?? (conn |> redirect(to: path(to: .login(redirect: conn.request.url?.absoluteString))))
    }
  }

//  return { conn in
//    conn.data.first.map {
//
//      conn.map(const($0 .*. conn.data.second)) |> middleware
//    }
//      ?? (conn |> writeStatus(.unauthorized) >-> respond(text: "not authorized"))
//  }
}

//let episodeResponse =
//  map(episode(for:))
//    >>> (
//      requireSome(notFoundView: episodeNotFoundView)
//        <| requestContextMiddleware
//        >-> writeStatus(.ok)
//        >-> respond(
//          episodeView.map(addHighlightJs >>> addGoogleAnalytics)
//      )
//)

let termsResponse =
   requireUser
      <| ( writeStatus(.ok)
      >-> respond(termsView) )

private let termsView = View<Tuple3<Database.User, URLRequest, Prelude.Unit>> { ctx in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        title("Terms of Service")
        ]),
      body(
        _navView.view(.some(ctx.first) .*. ctx.second) + [
        gridRow([
          gridColumn(sizes: [.xs: 12], [
            div([`class`([Class.padding.all(4)])], [
              h1([`class`([Class.h1])], ["Terms of Service"]),
              p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."]),
              p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."]),
              p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."]),
              p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."]),
              p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."])
              ])
            ])
          ])
        ] + footerView.view(unit))
      ])
    ])
}
