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

    return
      conn
      .writeStatus(.ok)
      .respondV2(
        layoutData: SimplePageLayoutData(
          description: clip.blurb,
          image: clip.posterURL,
          title: clip.title
        )
      ) {
        ClipView(clip: clip)
      }
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

    return
      conn
      .writeStatus(.ok)
      .respondV2(
        layoutData: SimplePageLayoutData(
          description: """
            A collection of some of our favorite moments from Point-Free episodes.
            """,
          title: "Point-Free Clips"
        )
      ) {
        ClipsIndex(clips: clips)
      }
  } catch {
    return await routeNotFoundMiddleware(conn).performAsync()
  }
}
