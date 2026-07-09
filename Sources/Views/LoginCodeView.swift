import Dependencies
import EmailAddress
import Models
import PointFreeRouter
import StyleguideV2

public struct LoginCodeView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let email: EmailAddress
  let redirect: String?

  public init(
    email: EmailAddress,
    redirect: String?
  ) {
    self.email = email
    self.redirect = redirect
  }

  private var codeInput: some HTML {
    input()
      .attribute("autocapitalize", "characters")
      .attribute("autocomplete", "one-time-code")
      .attribute("autofocus")
      .attribute("maxlength", "6")
      .attribute("name", "code")
      .attribute("placeholder", "ABC234")
      .attribute("required")
      .attribute("type", "text")
      .fontStyle(.body(.regular))
      .inlineStyle("border", "none")
      .inlineStyle("border-radius", "0.5rem")
      .inlineStyle("letter-spacing", "0.5rem")
      .inlineStyle("outline", "none")
      .inlineStyle("padding", "1rem 1.25rem")
      .inlineStyle("text-align", "center")
      .inlineStyle("text-transform", "uppercase")
  }

  private var codeForm: some HTML {
    form {
      VStack(spacing: 0.75) {
        input()
          .attribute("name", "email")
          .attribute("type", "hidden")
          .attribute("value", email.rawValue)
        codeInput
        Button(tag: input, color: .purple)
          .attribute("type", "submit")
          .attribute("value", "Log in")
      }
    }
  }

  public var body: some HTML {
    div {
      div {
        HTMLGroup {
          div {
            Header(2) { "Check your email" }
              .color(.offWhite)
          }
          .inlineStyle("display", "inline-block")
          Paragraph(.big) {
            "We’ve sent a 6-character login code to "
            strong { HTMLText(email.rawValue) }
            ". Enter it below to finish logging in."
          }
          .color(.gray850)
          codeForm
            // TODO: Point at the code redemption route once it exists.
            .attribute("action", "#")
            .attribute("method", "post")
            .inlineStyle("margin", "1.5rem auto 0")
            .inlineStyle("width", "100%")
            .inlineStyle("max-width", "22rem")
          div {
            Paragraph {
              "Didn’t receive the code? "
              Link(
                "Send a new one",
                href: siteRouter.path(for: .auth(.authLanding(kind: .login, redirect: redirect)))
              )
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
