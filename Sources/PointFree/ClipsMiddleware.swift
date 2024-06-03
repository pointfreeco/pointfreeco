import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Views
import VimeoClient

func clipsMiddleware(
  _ conn: Conn<StatusLineOpen, ClipsRoute>
) async -> Conn<ResponseEnded, Data> {
  switch conn.data {
  case let .clip(videoID: videoID):
    return await clipMiddleware(videoID: videoID, conn: conn.map(const(())))

  case .clips:
    return await clipsMiddleware(conn.map(const(())))
  }
}

private func clipMiddleware(
  videoID: VimeoVideo.ID,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.vimeoClient) var vimeoClient
  do {
    let video = try await vimeoClient.video(id: videoID)
    guard
      video.type == .video,
      video.privacy.view == .anybody
    else {
      return await routeNotFoundMiddleware(conn).performAsync()
    }

    return conn
      .writeStatus(.ok)
      .respond(
        view: vimeoVideoView(video:videoID:),
        layoutData: { 
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

private func clipsMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  do {
    let clips = try await database.fetchClips()
      .sorted { $0.order < $1.order }

    return conn
      .writeStatus(.ok)
      .respond(
        view: clipsView(clips:),
        layoutData: {
          SimplePageLayoutData(
            data: clips,
            description: """
              A collection of clips from our episodes.
              """,
            extraStyles: cardStyles,
            style: .base(.minimal(.black)),
            title: "Point-Free clips"
          )
        }
      )
  } catch {
    return await routeNotFoundMiddleware(conn).performAsync()
  }
}
