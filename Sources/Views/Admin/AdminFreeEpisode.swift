import Dependencies
import Foundation
import Models
import PointFreeRouter
import StyleguideV2

public struct FreeEpisodeAdminView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let episodes: [Episode]
  let today: Date
  let emergencyMode: Bool

  public init(
    episodes: [Episode],
    today: Date,
    emergencyMode: Bool
  ) {
    self.episodes = episodes
    self.today = today
    self.emergencyMode = emergencyMode
  }

  public var body: some HTML {
    let visibleEpisodes = episodes
      .filter { !$0.isSubscriberOnly(currentDate: today, emergencyMode: emergencyMode) }
      .sorted { $0.sequence > $1.sequence }

    PageModule(title: "Send free episode email", theme: .content) {
      ul {
        HTMLForEach(visibleEpisodes) { episode in
          li {
            HStack(alignment: .center, spacing: 1) {
              Paragraph { HTMLText(episode.fullTitle) }
              form {
                Button(tag: "input", color: .purple)
                  .attribute("type", "submit")
                  .attribute("value", "Send email!")
              }
              .attribute(
                "action",
                siteRouter.path(for: .admin(.freeEpisodeEmail(.send(episode.id))))
              )
              .attribute("method", "post")
            }
          }
        }
      }
    }
  }
}
