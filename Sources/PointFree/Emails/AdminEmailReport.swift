import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide

func adminEmailReport(_ type: String) -> View<([Database.User], Int)> {
  return simpleEmailLayout(adminEmailReportContent)
    .contramap { erroredUsers, totalAttempted in
      SimpleEmailLayoutData(
        user: nil,
        newsletter: nil,
        title: "\(type) email finished sending!",
        preheader: "\(totalAttempted) attempted emails, \(erroredUsers.count) errors",
        template: .default,
        data: (type, erroredUsers, totalAttempted)
      )
  }
}

let adminEmailReportContent = View<(String, [Database.User], Int)> { type, erroredUsers, totalAttempted in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 1], .desktop: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["New episode email report"]),
          p([
            "A total of ",
            strong([text("\(totalAttempted)")]),
            " emails were attempted to be sent, and of those, ",
            strong([text("\(erroredUsers.count)")]),
            " emails failed to send. Here is the list of users that we ",
            "had trouble sending to their emails:"
            ]),

          ul(erroredUsers.map { user in
            li([text(user.name.map { "\($0) (\(user.email)" } ?? user.email.rawValue)])
          })
          ])
        ])
      ])
    ])
}
