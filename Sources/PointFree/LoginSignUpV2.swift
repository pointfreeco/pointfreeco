import Dependencies
import Foundation
import Html
import HttpPipeline
import PointFreeRouter
import StyleguideV2
import Views

func loginSignUpMiddleware(
  redirect: String?,
  kind: SiteRoute.Auth.Kind?,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  let kind = kind ?? .signUp

  guard currentUser == nil
  else {
    return
      conn
      .redirect(to: .home) {
        $0.flash(.notice, "You’re already logged in.")
      }
  }

  return
    conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: "Point-Free: A hub for advanced programming in Swift.",
        title: {
          switch kind {
          case .login:
            "Log into Point-Free"
          case .signUp:
            "Sign up for Point-Free"
          case .slack:
            "Sign up to access community Slack"
          }
        }()
      )
    ) {
      LoginSignUpView(
        redirect: redirect,
        kind: kind
      )
    }
}
