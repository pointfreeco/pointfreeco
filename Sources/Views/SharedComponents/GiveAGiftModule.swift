import Dependencies
import StyleguideV2
import PointFreeRouter

struct GiveAGiftModule: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(theme: .callout) {
      Button(color: .purple, size: .regular, style: .normal) {
        "See gifts options"
      }
      .attribute("href", siteRouter.path(for: .gifts(.index)))
      .inlineStyle("margin", "0 auto")
    } title: {
      GridColumn {
        Header(3) { "Give the gift of Point-Free" }
          .color(.gray150.dark(.gray850))

        Paragraph(.big) {
          "Purchase a gift subscsription of 3, 6 or 12 months for a friend, colleague or loved one."
        }
        .fontStyle(.body(.regular))
        .color(.gray300.dark(.gray800))
        .inlineStyle("margin", "0 6rem", media: .desktop)
      }
      .inlineStyle("text-align", "start", media: .mobile)
    }
  }
}
