import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Views

func liveMiddleware(
  _ conn: Conn<StatusLineOpen, Live>
) -> Conn<ResponseEnded, Data> {
  switch conn.data {
  case .current:
    return currentLivestream(conn.map { _ in })
  }
}

private func currentLivestream(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  @Dependency(\.livestreams) var livestreams: [Livestream]
  let isLive = livestreams.first(where: \.isLive) != nil

  return
    conn
    .writeStatus(.ok)
    .respond(
      view: liveView,
      layoutData: {
        SimplePageLayoutData(
          description: isLive
            ? """
            We are livestreaming right now! Tune in to hear us discuss topics from episodes,
            explore our open source libraries, and take questions from our viewers.
            """
            : """
            Point-Free Live is a periodic livestream where we discuss topics from episodes, explore
            our open source libraries, and take questions from our viewers.
            """,
          style: .base(.minimal(.black)),
          title: "🔴 Point-Free Live"
        )
      }
    )
}
