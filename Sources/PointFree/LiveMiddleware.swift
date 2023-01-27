import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Views
import VimeoClient

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
  @Dependency(\.vimeoClient) var vimeoClient
  do {
    let video = try await vimeoClient.video(conn.data)
    guard video.type == .live
    else {
      return await routeNotFoundMiddleware(conn).performAsync()
    }

    return
      conn
      .writeStatus(.ok)
      .respond(
        view: vimeoVideoView(video:videoID:),
        layoutData: { videoID in
          SimplePageLayoutData(
            data: (video, videoID),
            description: video.description,
            style: .base(.minimal(.black)),
            title: "\(video.name)"
          )
        }
      )
  } catch {
    return await routeNotFoundMiddleware(conn).performAsync()
  }
}
