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
  @Dependency(\.database) var database
  do {
    switch conn.data {
    case let .clip(cloudflareVideoID: cloudflareVideoID):
      let clip = try await database.fetchClip(cloudflareVideoID: cloudflareVideoID)
      return await clipMiddleware(clip: clip, conn: conn.map(const(())))

    case .clips:
      return await clipsMiddleware(conn.map(const(())))
    }
  } catch {
    return await routeNotFoundMiddleware(conn).performAsync()
  }
}

private func clipMiddleware(
  clip: Clip,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
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
}

private func clipsMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  do {
    let clips = try await database.fetchClips(includeHidden: false)

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
