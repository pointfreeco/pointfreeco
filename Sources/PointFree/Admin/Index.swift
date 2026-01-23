import Dependencies
import EmailAddress
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import StyleguideV2
import Tuple
import Views

public let adminEmails: [EmailAddress] = [
  "brandon@pointfree.co",
  "stephen@pointfree.co",
]

func adminIndex(_ conn: Conn<StatusLineOpen, Void>) -> Conn<ResponseEnded, Data> {
  conn.writeStatus(.ok)
    .respondV2(layoutData: SimplePageLayoutData(title: "Admin Dashboard")) {
      AdminIndexView()
    }
}

private struct AdminIndexView: HTML {
  var body: some HTML {
    PageModule(title: "Admin Dashboard", theme: .content) {
      ul {
        li { Link("Send new episode email", destination: .admin(.newEpisodeEmail())) }
        li { Link("Send episode credits", destination: .admin(.episodeCredits())) }
        li { Link("Send free episode email", destination: .admin(.freeEpisodeEmail())) }
        li { Link("Send new blog post email", destination: .admin(.newBlogPostEmail())) }
        li { Link("Ghost a user", destination: .admin(.ghost())) }
        li { Link("Preview an email", destination: .admin(.emailPreview(template: nil))) }
      }
    }
  }
}
