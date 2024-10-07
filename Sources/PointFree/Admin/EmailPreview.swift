import Dependencies
import Foundation
import FunctionalCss
import GitHub
import Html
import HtmlCssSupport
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Styleguide
import StyleguideV2

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
    .iframe(
      attributes: [
        .init("srcdoc", render(selectedTemplate.map(email(selectedTemplate:)) ?? [])),
        .width(.pct(100)),
        .height(.pct(100)),
      ]
    ),
  ]
}

private func email(selectedTemplate: EmailTemplate) -> Node {
  switch selectedTemplate {
  case .joinTeamConfirmation:
    return try! confirmationEmail(
      email: "blob@pointfree.co",
      code: "pointfree.co",
      currentUser: blob
    )
  case .newTeammateJoined:
    return newTeammateEmail(
      currentUser: blob,
      owner: blobJr,
      code: "pointfree.co"
    )
  case .ownerNewTeammateJoined:
    return ownerNewTeammateJoinedEmail(
      currentUser: blob,
      owner: blobJr,
      newPricing: Pricing(billing: .yearly, quantity: 7)
    )
  case .updateGitHubAccount:
    return Node {
      GitHubAccountUpdateEmail(
        newGitHubUser: GitHubUser(
          createdAt: Date(),
          login: "mbrandonw",
          id: 135203,
          name: "Brandon Williams"
        )
      )
    }
  case .welcomeEmail1:
    return Node { WelcomeEmailWeek1(user: blob) }
  case .welcomeEmail2:
    return Node { WelcomeEmailWeek2(freeEpisodeCount: 123, user: blob) }
  case .welcomeEmail3:
    return Node { WelcomeEmailWeek3(user: blob) }
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
    case .joinTeamConfirmation:
      "Join team confirmation"
    case .newTeammateJoined:
      "New teammate joined"
    case .ownerNewTeammateJoined:
      "Notify owner new teammate joined"
    case .updateGitHubAccount:
      "Update GitHub account"
    case .welcomeEmail1:
      "Welcome Email #1"
    case .welcomeEmail2:
      "Welcome Email #2"
    case .welcomeEmail3:
      "Welcome Email #3"
    }
  }
}

private let blob = User(
  email: "blob@pointfree.co",
  episodeCreditCount: 1,
  gitHubUserId: 1,
  gitHubAccessToken: "",
  id: User.ID(),
  isAdmin: false,
  name: "Blob",
  referralCode: "",
  referrerId: User.ID(),
  rssSalt: "",
  subscriptionId: Subscription.ID()
)

private let blobJr = User(
  email: "blob.jr@pointfree.co",
  episodeCreditCount: 1,
  gitHubUserId: 1,
  gitHubAccessToken: "",
  id: User.ID(),
  isAdmin: false,
  name: "Blob Jr.",
  referralCode: "",
  referrerId: User.ID(),
  rssSalt: "",
  subscriptionId: Subscription.ID()
)
