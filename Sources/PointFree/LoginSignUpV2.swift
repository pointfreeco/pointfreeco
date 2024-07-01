import Dependencies
import Foundation
import Html
import HttpPipeline
import PointFreeRouter
import StyleguideV2
import Views

func loginSignUpMiddleware(
  redirect: String?,
  type: LoginSignUpView.LoginSignUpType,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser

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
        description: "Point-Free: A video series exploring advanced programming topics in Swift.",
        title: {
          switch type {
          case .login:
            "Log into Point-Free"
          case .signUp:
            "Sign up for Point-Free"
          }
        }()
      )
    ) {
      LoginSignUpView(
        redirect: redirect,
        type: type
      )
    }
}
