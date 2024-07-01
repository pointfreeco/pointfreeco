import Dependencies
import Models
import StyleguideV2

struct ReferAFriendModule: HTML {
  let user: User

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    div {
      VStack(alignment: .leading, spacing: 1) {
        div {
          Header(3) { HTMLText("Refer a friend") }
            .color(.gray150.dark(.gray850))
        }

        div {
          Paragraph(.big) {
            """
            You'll both get one month free ($18 credit) when they sign up from your personal \
            referral link:
            """
          }
          .color(.gray300.dark(.gray800))
          .inlineStyle("max-width", "40rem", media: .desktop)
          .inlineStyle("text-align", "center", media: .desktop)
        }

        let url = String(
          siteRouter.url(
            for: .subscribeConfirmation(
              lane: .personal,
              referralCode: user.referralCode
            )
          )
          .dropFirst(8)
        )

        HStack(alignment: .center) {
          input()
            .color(.gray500)
            .grow()
            .attribute("value", url)
            .attribute("type", "text")
            .attribute("readonly")
            .attribute("onclick", "this.select();")
            .inlineStyle("border", "1px solid #eee")
            .inlineStyle("border-radius", "0.5rem")
            .inlineStyle("padding", "1rem")
            .inlineStyle("outline", "none")
            .inlineStyle("width", "100%")

          Button(tag: input, color: .purple, size: .regular, style: .normal)
            .attribute("type", "button")
            .attribute("value", "Copy")
            .attribute(
              "onclick",
              """
              navigator.clipboard.writeText("\(url)");
              this.value = "Copied!";
              setTimeout(() => { this.value = "Copy"; }, 3000);
              """
            )
        }
        .inlineStyle("margin-top", "1rem")
      }
      .inlineStyle("max-width", "1280px")
      .inlineStyle("margin", "0 auto")
      .inlineStyle("align-items", "center", media: .desktop)
      .backgroundColor(.init(rawValue: "#fafafa").dark(.init(rawValue: "#050505")))
      .inlineStyle("padding", "4rem 2rem")
      .inlineStyle("padding", "4rem 3rem", media: .desktop)
    }
    .inlineStyle("padding", "0 2rem", media: .desktop)
    .inlineStyle("max-width", "100%")
    .backgroundColor(.white.dark(.black))
  }
}
