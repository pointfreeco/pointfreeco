import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude

let subscribeResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data?>> =
  writeStatus(.ok)
    >>> readGitHubSessionCookieMiddleware
    >>> respond(subscribeView)
    >>> pure

//<script src="https://js.stripe.com/v3/"></script>

private let subscribeView = View<Either<Prelude.Unit, GitHubUserEnvelope>> { data in
  document([
    html([
      head([
        script([src("https://js.stripe.com/v3/")])
        ]),

      body([
        h1(["Subscribe to Point-Free"]),

        a([href(link(to: .secretHome))], ["Home"]),

        div([
          h3(["Monthly"]),
          h3(["$9"])
          ]),

        div([
          h3(["Year"]),
          h3(["$90"])
          ]),

        data.isRight
          ? a([href("#")], ["Subscribe now!"])
          : a([href(link(to: .login(redirect: link(to: .subscribe))))], ["Login with GitHub!"]),

        p(["Subscriptions can be cancelled at any time."])
        ])
      ])
    ])
}
