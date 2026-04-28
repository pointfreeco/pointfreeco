import Dependencies
import EmailAddress
import Either
import Foundation
import FunctionalCss
import GitHub
import Html
import HtmlCssSupport
import HttpPipeline
import IssueReporting
import Models
import PointFreeDependencies
import PointFreeRouter
import Styleguide
import StyleguideV2
import TaggedMoney
import Views

func emailPreview(
  _ conn: Conn<StatusLineOpen, Void>,
  template: EmailTemplate?,
  status: EmailPreviewStatus? = nil
) async -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respond(
      view: emailPreviewView,
      layoutData: { SimplePageLayoutData(data: EmailPreviewData(selectedTemplate: template, status: status), title: "Email preview") }
    )
}

func sendTestEmail(
  _ conn: Conn<StatusLineOpen, Void>,
  template: EmailTemplate,
  recipientEmail: String
) async -> Conn<ResponseEnded, Data> {
  let emailAddress = EmailAddress(rawValue: recipientEmail)

  guard isValidEmail(emailAddress)
  else {
    return await emailPreview(
      conn,
      template: template,
      status: .error("Please enter a valid email address.")
    )
  }

  do {
    _ = try await send(
      email: prepareEmail(
        to: [emailAddress],
        cc: [supportEmail],
        subject: "[Preview] \(template.displayName)",
        content: inj2(email(selectedTemplate: template))
      )
    )
    return await emailPreview(
      conn,
      template: template,
      status: .notice("Sent a test email to \(recipientEmail).")
    )
  } catch {
    reportIssue(error, "Unable to send test email preview")
    return await emailPreview(
      conn,
      template: template,
      status: .error("Could not send the test email.")
    )
  }
}

private func emailPreviewView(data: EmailPreviewData) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .fragment(
      data.status.map { [statusBanner($0)] } ?? []
    ),
    .div(
      .form(
        attributes: [
          .id("email-form"),
          .action(siteRouter.path(for: .admin(.emailPreview()))),
          .method(.post),
        ],
        .label(
          attributes: [.for("template")],
          "Preview template"
        ),
        .select(
          attributes: [
            .id("template"),
            .name("template"),
            .onchange(
              unsafe: """
                document.getElementById("email-form").submit();
                """
            ),
          ],
          .fragment(options(selectedTemplate: data.selectedTemplate))
        )
      ),
      .form(
        attributes: [
          .action(siteRouter.path(for: .admin(.emailPreview()))),
          .method(.post),
        ],
        .fragment(
          data.selectedTemplate.map { template in
            [
              .input(attributes: [
                .name("template"),
                .type(.hidden),
                .value(template.rawValue),
              ])
            ]
          } ?? []
        ),
        .label(
          attributes: [.for("test-email"), .class([Class.margin([.mobile: [.right: 1]])])],
          "Send test email"
        ),
        .input(attributes: [
          .id("test-email"),
          .name("email"),
          .type(.email),
          .placeholder("blob@example.com"),
          .required(true),
          .disabled(data.selectedTemplate == nil),
        ]),
        .text(" "),
        .input(attributes: [
          .type(.submit),
          .value("Send"),
          .disabled(data.selectedTemplate == nil),
          .class([Class.pf.components.button(color: .purple, size: .small)]),
        ])
      )
    )
    ,
    data.selectedTemplate == nil
      ? .p(
        "Choose a template to preview it and enable test sends."
      )
      : [],
    .iframe(
      attributes: [
        .init("srcdoc", render(data.selectedTemplate.map(email(selectedTemplate:)) ?? [])),
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
  case .maxWelcomeEmail:
    return Node { MaxWelcomeEmail(user: blob) }
  case .proWelcomeEmail:
    return Node { ProWelcomeEmail(user: blob) }
  case .newBlogPost:
    @Dependency(\.blogPosts) var blogPosts
    return newBlogPostEmail(
      (
        blogPosts().last!,
        "This is a test announcement for members.",
        "This is a test announcement for non-members.",
        blob
      )
    )

  case .newEpisode:
    @Dependency(\.episodes) var episodes
    return newEpisodeEmail(
      (
        episodes().last!,
        "This is a test announcement for members.",
        "This is a test announcement for non-members.",
        blob
      )
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
      newPricing: NewPricing(amount: 192_00, interval: .year, quantity: 7)
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

private func statusBanner(_ status: EmailPreviewStatus) -> Node {
  let message =
    switch status {
    case .error(let message):
      "Error: \(message)"
    case .notice(let message):
      message
    }

  return .p(.text(message))
}

private struct EmailPreviewData {
  let selectedTemplate: EmailTemplate?
  let status: EmailPreviewStatus?
}

enum EmailPreviewStatus {
  case error(String)
  case notice(String)
}

extension EmailTemplate {
  var displayName: String {
    switch self {
    case .joinTeamConfirmation:
      "Join team confirmation"
    case .maxWelcomeEmail:
      "Max Welcome Email"
    case .proWelcomeEmail:
      "Pro Welcome Email"
    case .newBlogPost:
      "New blog post"
    case .newEpisode:
      "New video"
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
