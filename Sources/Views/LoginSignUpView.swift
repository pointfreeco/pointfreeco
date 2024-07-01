import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

public struct LoginSignUpView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let redirect: String?
  let type: LoginSignUpType

  public enum LoginSignUpType {
    case login
    case signUp
  }

  public init(
    redirect: String?,
    type: LoginSignUpType
  ) {
    self.redirect = redirect
    self.type = type
  }

  public var body: some HTML {
    div {
      div {
        HTMLGroup {
          div {
            Header(2) {
              switch type {
              case .login: "Log in"
              case .signUp: "Sign up"
              }
            }
            .color(.offWhite)
          }
          Button(color: .purple) {
            Label("Continue with GitHub", icon: .gitHubIcon)
              .fontStyle(.body(.regular))
          }
          .attribute(
            "href",
            siteRouter.path(for: .gitHubAuth(redirect: redirect))
          )
          div {
            Paragraph {
              """
              By clicking “Continue with Github” above, you acknowledge that you have read, \
              understood, and agree to Point-Free’s
              """
              " "
              Link.init("Terms & Privacy Policy", href: siteRouter.path(for: .privacy))
              "."
            }
            .linkStyle(.init(color: .init(rawValue: "#999"), underline: true))
            .inlineStyle("color", "#999")
          }
          .inlineStyle("text-align", "center")
          .inlineStyle("padding-top", "1.5rem")
          .inlineStyle("max-width", "30rem")
          .fontStyle(.body(.small))
        }
        .flexItem(grow: "0", shrink: "0", basis: "100%")
      }
      .inlineStyle("padding", "10rem 0")
      .inlineStyle("margin", "0 auto")
      .inlineStyle("max-width", "1280px")
      .flexContainer(
        direction: "column",
        wrap: "wrap",
        justification: "center",
        itemAlignment: "center",
        rowGap: "2.5rem"
      )
    }
    .inlineStyle("background", "linear-gradient(#121212, #291a40)")
  }
}
