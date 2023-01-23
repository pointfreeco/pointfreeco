import Foundation
import HttpPipeline
import Views

func liveMiddleware(
  _ conn: Conn<StatusLineOpen, Int>
) async -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respond(
      view: liveView,
      layoutData: { id in
        SimplePageLayoutData(
          data: id,
          description: """
            Now streaming live!
            """,
          style: .base(.minimal(.black)),
          title: "Point-Free Live"
        )
      }
    )
}
