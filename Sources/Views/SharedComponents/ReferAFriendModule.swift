import Dependencies
import Models
import StyleguideV2

struct ReferAFriendModule: HTML {
  let user: User

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(theme: .referAFriend) {
      let url = siteRouter.url(
        for: .subscribeConfirmation(
          lane: .personal,
          referralCode: user.referralCode
        )
      )

      Grid {
        GridColumn {
          input()
            .attribute("value", url)
            .attribute("type", "text")
            .attribute("readonly", "true")
            .attribute("onclick", "this.select();")
            .inlineStyle("width", "100%")
            .inlineStyle("border-radius", "0.5rem")
            .color(.gray500)
            .inlineStyle("padding", "1rem")
            .inlineStyle("border", "none")
            .inlineStyle("outline", "none")
        }
        .flexible()
        .inlineStyle("padding-right", "1rem")
        .inlineStyle("max-width", "60%", media: .desktop)

        GridColumn {
          Button.input(color: .purple, size: .regular, style: .normal) 
            .attribute("type", "button")
            .attribute("value", "Copy")
            .attribute("onclick", """
                navigator.clipboard.writeText("\(url)");
                this.value = "Copied!";
                setTimeout(() => { this.value = "Copy"; }, 3000);
                """)
        }
        .inflexible()
      }
      .column(count: 12)
      .grid(alignment: .center)
      .inlineStyle("justify-content", "center")
      .inlineStyle("margin", "2rem 4rem")
    } title: {
      Header(2) { "Refer a friend" }
        .color(.gray150)

      Paragraph(.big) {
        """
        You'll both get one month free ($18 credit) when they sign up from your personal \
        referral link:
        """
      }
      .fontStyle(.body(.regular))
      .color(.gray300)
      .inlineStyle("margin", "0 6rem", media: .desktop)
    }
  }
}

extension PageModuleTheme {
  static let referAFriend = Self(
    backgroundColor: .white.dark(.black),
    contentBackgroundColor: .init(rawValue: "#fafafa").dark(.init(rawValue: "#050505")),
    color: .offBlack.dark(.offWhite),
    topMargin: 4,
    bottomMargin: 4,
    leftRightMargin: 2,
    leftRightMarginDesktop: 3,
    titleMarginBottom: 0
  )
}
