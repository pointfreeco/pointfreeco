import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Views

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
  @Dependency(\.database) var database
  do {
    let clip = try await database.fetchClip(vimeoVideoID: videoID)

    return conn
      .writeStatus(.ok)
      .respond(
        view: clipView(clip:),
        layoutData: {
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

private func clipsMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  do {
    let clips = try await database.fetchClips()
      .filter { $0.order >= 0 }
      .sorted { $0.order < $1.order }

    return conn
      .writeStatus(.ok)
      .respond(
        view: clipsView(clips:),
        layoutData: {
          SimplePageLayoutData(
            data: clips,
            description: """
              A collection of some of our favorite moments from Point-Free episodes.
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
