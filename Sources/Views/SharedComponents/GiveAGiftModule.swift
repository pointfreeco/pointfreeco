import Dependencies
import PointFreeRouter
import StyleguideV2

struct GiveAGiftModule: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    CalloutModule(
      title: "Give the gift of Point-Free",
      subtitle: """
        Purchase a gift subscsription of 3, 6 or 12 months for a friend, colleague or loved one.
        """,
      ctaTitle: "See gifts options",
      ctaURL: siteRouter.path(for: .gifts(.index))
    )
  }
}
