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
) async -> Conn<ResponseEnded, Data> {
  switch conn.data {
  case .current:
    return await currentLivestream(conn.map(const(())))

  case let .stream(id: id):
    return await stream(conn.map(const(id)))
  }
}

private func currentLivestream(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.livestreams) var livestreams: [Livestream]
  let isLive = livestreams.first(where: { $0.isLive }) != nil

  return
    conn
    .writeStatus(.ok)
    .respond(
      view: liveView,
      layoutData: {
        SimplePageLayoutData(
          data: (),
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

private func stream(
  _ conn: Conn<StatusLineOpen, VimeoVideo.ID>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  do {
    let clip = try await database.fetchClip(vimeoVideoID: conn.data)
    return
      conn
      .writeStatus(.ok)
      .respond(
        view: clipView(clip:),
        layoutData: { videoID in
          SimplePageLayoutData(
            data: clip,
            description: clip.description,
            style: .base(.minimal(.black)),
            title: clip.title
          )
        }
      )
  } catch {
    return await routeNotFoundMiddleware(conn).performAsync()
  }
}
