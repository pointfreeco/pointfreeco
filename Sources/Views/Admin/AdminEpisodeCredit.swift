import Dependencies
import PointFreeRouter
import StyleguideV2

public struct EpisodeCreditView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  public init() {}

  public var body: some HTML {
    PageModule(title: "Create an episode credit!", theme: .content) {
      form {
        VStack(alignment: .leading, spacing: 1) {
          input()
            .attribute("name", "user_id")
            .attribute("placeholder", "User ID")
            .attribute("type", "text")
          input()
            .attribute("name", "episode_sequence")
            .attribute("placeholder", "Episode sequence #")
            .attribute("type", "text")
          Button(tag: "input", color: .purple)
            .attribute("type", "submit")
            .attribute("value", "Create")
        }
      }
      .attribute("method", "post")
      .attribute(
        "action",
        siteRouter.path(for: .admin(.episodeCredits(.add(userId: nil, episodeSequence: nil))))
      )
    }
  }
}
