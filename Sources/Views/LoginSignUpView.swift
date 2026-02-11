import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

public struct LoginSignUpView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let redirect: String?
  let kind: SiteRoute.Auth.Kind

  public init(
    redirect: String?,
    kind: SiteRoute.Auth.Kind
  ) {
    self.redirect = redirect
    self.kind = kind
  }

  public var body: some HTML {
    div {
      div {
        HTMLGroup {
          div {
            Header(2) {
              switch kind {
              case .login: "Log in"
              case .signUp: "Sign up"
              case .slack: "Point-Free Slack"
              }
            }
            .color(.offWhite)
            if kind == .slack {
              MembersOnlyBadge()
            }
          }
          .inlineStyle("display", "inline-block")
          .inlineStyle("position", "relative")
          if kind == .slack {
            Paragraph(.big) {
            """
            Join thousands of Swift developers in our Slack community. \
            Access is available to Point-Free members.
            """
            }
            .color(.gray850)
          }
          Button(color: .purple) {
            Label("Continue with GitHub", icon: .gitHubIcon)
              .fontStyle(.body(.regular))
          }
          .attribute(
            "href",
            siteRouter.path(for: .auth(.gitHubAuth(redirect: redirect)))
          )
          div {
            Paragraph {
              """
              By clicking “Continue with GitHub” above, you acknowledge that you have read, \
              understood, and agree to Point-Free’s
              """
              " "
              Link("Terms & Privacy Policy", href: siteRouter.path(for: .privacy))
              "."
            }
            .linkStyle(.init(color: .init(rawValue: "#999"), underline: true))
            .inlineStyle("color", "#999")
          }
          .inlineStyle("padding-top", "1.5rem")
          .inlineStyle("max-width", "30rem")
          .fontStyle(.body(.small))
        }
        .inlineStyle("text-align", "center")
        .inlineStyle("max-width", "40rem")
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

private struct MembersOnlyBadge: HTML {
  var body: some HTML {
    tag("members only") {
      "MEMBERS ONLY"
    }
    .inlineStyle("font-size", "0.65rem")
    .inlineStyle("font-weight", "700")
    .inlineStyle("letter-spacing", "0.08em")
    .inlineStyle("padding", "2px 6px")
    .inlineStyle("border-radius", "999px")
    .inlineStyle("border", "1px solid rgba(255, 208, 77, 0.7)")
    .inlineStyle("background", "rgba(255, 214, 102, 0.5)")
    .inlineStyle("color", "rgba(255, 255, 255, 0.75)")
    .inlineStyle("white-space", "nowrap")
    .inlineStyle("position", "absolute")
    .inlineStyle("top", "0")
    .inlineStyle("right", "0")
    .inlineStyle("transform", "translate(55%, -55%)")
  }
}
