import Dependencies
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Styleguide

func emailPreview(
  _ conn: Conn<StatusLineOpen, EmailTemplate?>
) async -> Conn<ResponseEnded, Data> {

  conn
    .writeStatus(.ok)
    .respond(
      view: emailPreviewView,
      layoutData: { .init(data: $0, title: "Email preview") }
    )
}

private func emailPreviewView(selectedTemplate: EmailTemplate?) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .form(
      attributes: [
        .id("email-form"),
        .action(siteRouter.path(for: .admin(.emailPreview(template: nil)))),
        .method(.post),
      ],
      .select(
        attributes: [
          .name("template"),
          .onchange(
            unsafe: """
              document.getElementById("email-form").submit();
              """),
        ],
        .fragment(options(selectedTemplate: selectedTemplate))
      )
    ),
    .div(
      attributes: [
        .class([Class.padding([.mobile: [.all: 2], .desktop: [.all: 4]])])
      ],
      selectedTemplate
        .map(email(selectedTemplate:))
        ?? []
    ),
  ]
}

private func email(selectedTemplate: EmailTemplate) -> Node {
  switch selectedTemplate {
  case .welcomeEmail1:
    return welcomeEmail1Content(
      user: .init(
        email: "", episodeCreditCount: 1, gitHubUserId: 1, gitHubAccessToken: "", id: User.ID(),
        isAdmin: false, name: "Blob", referralCode: "", referrerId: User.ID(), rssSalt: "",
        subscriptionId: Subscription.ID()))
  case .welcomeEmail2:
    return welcomeEmail2Content(
      user: .init(
        email: "", episodeCreditCount: 1, gitHubUserId: 1, gitHubAccessToken: "", id: User.ID(),
        isAdmin: false, name: "Blob", referralCode: "", referrerId: User.ID(), rssSalt: "",
        subscriptionId: Subscription.ID()))
  case .welcomeEmail3:
    return welcomeEmail3Content(
      user: .init(
        email: "", episodeCreditCount: 1, gitHubUserId: 1, gitHubAccessToken: "", id: User.ID(),
        isAdmin: false, name: "Blob", referralCode: "", referrerId: User.ID(), rssSalt: "",
        subscriptionId: Subscription.ID()))
  }
}

private func options(selectedTemplate: EmailTemplate?) -> [ChildOf<Tag.Select>] {
  var options = EmailTemplate.allCases.map { template in
    ChildOf<Tag.Select>.option(
      attributes: [
        .selected(template == selectedTemplate),
        .value(template.rawValue),
      ],
      template.displayName
    )
  }
  options.prepend(.init(arrayLiteral: .option(attributes: [], "None")))
  return options
}

extension EmailTemplate {
  var displayName: String {
    switch self {
    case .welcomeEmail1:
      return "Welcome Email #1"
    case .welcomeEmail2:
      return "Welcome Email #2"
    case .welcomeEmail3:
      return "Welcome Email #3"
    }
  }
}
