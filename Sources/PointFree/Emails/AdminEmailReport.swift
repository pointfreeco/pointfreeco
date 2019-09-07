import Css
import FunctionalCss
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Optics
import Prelude
import Styleguide
import View

public func adminEmailReport(_ type: String) -> ((erroredUsers: [User], totalAttempted: Int)) -> [Node] {
  return { data in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "\(type) email finished sending!",
      preheader: "\(data.totalAttempted) attempted emails, \(data.erroredUsers.count) errors",
      template: .default,
      data: (type, data.erroredUsers, data.totalAttempted)
    )
    } >>> simpleEmailLayout(adminEmailReportContent)
}

func adminEmailReportContent(data: (type: String, erroredUsers: [User], totalAttempted: Int)) -> [Node] {
  return [
    emailTable([style(contentTableStyles)], [
      tr([
        td([valign(.top)], [
          div([`class`([Class.padding([.mobile: [.all: 1], .desktop: [.all: 2]])])], [
            h3([`class`([Class.pf.type.responsiveTitle3])], ["New episode email report"]),
            p([
              "A total of ",
              strong([.text("\(data.totalAttempted)")]),
              " emails were attempted to be sent, and of those, ",
              strong([.text("\(data.erroredUsers.count)")]),
              " emails failed to send. Here is the list of users that we ",
              "had trouble sending to their emails:"
              ]),

            ul(data.erroredUsers.map { user in
              li([.text(user.name.map { "\($0) (\(user.email)" } ?? user.email.rawValue)])
            })
            ])
          ])
        ])
      ])
  ]
}
