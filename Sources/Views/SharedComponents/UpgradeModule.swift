import Dependencies
import StyleguideV2

struct UpgradeModule: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(theme: .callout) {
      Button(color: .purple, size: .regular, style: .normal) {
        "See plans and pricing"
      }
      .attribute("href", siteRouter.path(for: .pricingLanding))
      .inlineStyle("margin", "0 auto")
    } title: {
      Header(2) { "Upgrade your plan" }
        .color(.gray150)

      Paragraph(.big) { "Access all past and future episodes." }
        .fontStyle(.body(.regular))
        .color(.gray300)
        .inlineStyle("margin", "0 6rem", media: MediaQuery.desktop.rawValue)
    }
  }
}
