import Css
import Either
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Prelude
import Styleguide

public func adminEmailReport(_ type: String) -> ((erroredUsers: [User], totalAttempted: Int)) ->
  Node
{
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

func adminEmailReportContent(data: (type: String, erroredUsers: [User], totalAttempted: Int))
  -> Node
{
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 1], .desktop: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])],
            "New episode email report"
          ),
          .p(
            "A total of ",
            .strong(.text("\(data.totalAttempted)")),
            " emails were attempted to be sent, and of those, ",
            .strong(.text("\(data.erroredUsers.count)")),
            " emails failed to send. Here is the list of users that we ",
            "had trouble sending to their emails:"
          ),

          .ul(
            .fragment(
              data.erroredUsers.map { user in
                .li(.text(user.name.map { "\($0) (\(user.email)" } ?? user.email.rawValue))
              }
            )
          )
        )
      )
    )
  )
}
