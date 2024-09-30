import Dependencies
import StyleguideV2

struct GetStartedModule: HTML {
  @Dependency(\.date.now) var now
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.episodes) var episodes
  @Dependency(\.siteRouter) var siteRouter

  let style: CallToActionHeaderStyle

  var body: some HTML {
    let freeEpisodeCount = episodes()
      .reduce(into: 0) { count, episode in
        count += !episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode) ? 1 : 0
      }
    CallToActionHeader(
      title: "Get started with our free&nbsp;plan",
      blurb: """
        Our free plan includes 1 subscriber-only episode of your choice, access to \
        \(freeEpisodeCount) free episodes with transcripts and code samples, and weekly updates \
        from our newsletter.
        """,
      ctaTitle: "Sign up for free →",
      ctaURL: siteRouter.path(for: .auth(.signUp(redirect: nil))),
      secondaryCTATitle: "View plans and pricing",
      secondaryCTAURL: siteRouter.path(for: .pricingLanding),
      style: style
    )
  }
}
