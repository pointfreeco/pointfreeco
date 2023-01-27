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
    return await clipMiddleware(conn.map(const(videoID)))
  }
}

private func clipMiddleware(
  _ conn: Conn<StatusLineOpen, VimeoVideo.ID>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.vimeoClient) var vimeoClient
  do {
    let video = try await vimeoClient.video(conn.data)
    guard video.type == .video
    else { return await routeNotFoundMiddleware(conn).performAsync() }

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
