import Dependencies
import StyleguideV2

struct UpgradeModule: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    CalloutModule(
      title: "Upgrade your plan",
      subtitle: "Access all past and future videos and the Point-Free Way.",
      ctaTitle: "See plans and pricing",
      ctaURL: siteRouter.path(for: .pricingLanding)
    )
  }
}
