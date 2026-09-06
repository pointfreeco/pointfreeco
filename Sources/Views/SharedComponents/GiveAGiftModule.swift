import Dependencies
import PointFreeRouter
import StyleguideV2

struct GiveAGiftModule: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    CalloutModule(
      title: "Give the gift of Point-Free",
      subtitle: """
        Purchase a Point-Free membership for a friend, colleague or loved one.
        """,
      ctaTitle: "See gifts options",
      ctaURL: siteRouter.path(for: .gifts(.index))
    )
  }
}
