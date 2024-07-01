import Dependencies
import StyleguideV2

struct UpgradeModule: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    CalloutModule(
      title: "Upgrade your plan",
      subtitle: "Access all past and future episodes.",
      ctaTitle: "See plans and pricing",
      ctaURL: siteRouter.path(for: .pricingLanding)
    )
  }
}
