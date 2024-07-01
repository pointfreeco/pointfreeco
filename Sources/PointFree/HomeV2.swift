import Dependencies
import Foundation
import Html
import HttpPipeline
import PointFreeRouter
import StyleguideV2
import Views

func homeV2Middleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.episodes) var episodes
  @Dependency(\.date.now) var now
  @Dependency(\.database) var database
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState

  let creditCount: Int
  if let credits = currentUser?.episodeCreditCount, !subscriberState.isActiveSubscriber {
    creditCount = credits
  } else {
    creditCount = 0
  }

  let clips = (try? await database.fetchClips()) ?? []

  return
    conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: "Point-Free: A video series exploring advanced programming topics in Swift.",
        title: "Point-Free"
      )
    ) {
      Home(
        allFreeEpisodeCount: episodes()
          .filter { !$0.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode) }
          .count,
        creditCount: creditCount,
        clips: clips
      )
    }
}
