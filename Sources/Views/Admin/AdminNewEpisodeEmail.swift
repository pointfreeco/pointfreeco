import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

public struct AdminNewEpisodeEmailView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let episodes: [Episode]

  public init(episodes: [Episode]) {
    self.episodes = episodes
  }

  public var body: some HTML {
    PageModule(title: "Send new episode email", theme: .content) {
      VStack(alignment: .leading, spacing: 2) {
        HTMLForEach(episodes) { episode in
          VStack(alignment: .leading, spacing: 1) {
            Header(4) { "Episode #\(episode.sequence): \(episode.fullTitle)" }
            form {
              VStack(alignment: .leading, spacing: 0.75) {
                textarea { "" }
                  .attribute("name", "subscriber_announcement")
                  .attribute("placeholder", "Subscriber announcement")
                textarea { "" }
                  .attribute("name", "nonsubscriber_announcement")
                  .attribute("placeholder", "Non-subscribers announcements")
                HStack(alignment: .center, spacing: 0.5) {
                  Button(tag: "input", color: .black, style: .outline)
                    .attribute("type", "submit")
                    .attribute("name", "test")
                    .attribute("value", "Test email!")
                  Button(tag: "input", color: .purple)
                    .attribute("type", "submit")
                    .attribute("name", "live")
                    .attribute("value", "Send email!")
                }
              }
            }
            .attribute(
              "action",
              siteRouter.path(for: .admin(.newEpisodeEmail(.send(episode.id))))
            )
            .attribute("method", "post")
          }
        }
      }
    }
  }
}
