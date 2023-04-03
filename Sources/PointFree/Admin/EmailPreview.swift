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

enum EmailTemplate: String, CaseIterable {
  case welcomeEmail1 = "Welcome Email #1"
  case welcomeEmail2 = "Welcome Email #2"
  case welcomeEmail3 = "Welcome Email #3"
}

func emailPreview(
  _ conn: Conn<StatusLineOpen, String?>
) async -> Conn<ResponseEnded, Data> {

  conn
    .writeStatus(.ok)
    .respond(
      view: view,
      layoutData: {
        .init(
          data: $0,
          //            description: <#T##String?#>,
          //            extraHead: <#T##ChildOf<Tag.Head>#>,
          //            extraStyles: <#T##Stylesheet#>,
          //            image: <#T##String?#>,
          //            isGhosting: <#T##Bool#>,
          //            openGraphType: <#T##OpenGraphType#>,
          //            style: <#T##SimplePageLayoutData<String?>.Style#>,
          title: "Email preview"  //,
            //            twitterCard: <#T##TwitterCard#>,
            //            usePrismJs: <#T##Bool#>
        )
      }
    )
}

private func view(email: String?) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .form(
      attributes: [
        .id("email-form"),
        .action(siteRouter.path(for: .admin(.emailPreview(id: nil)))),
        .method(.post),
      ],
      .select(
        attributes: [
          .name("email"),
          .onchange(
            unsafe: """
              document.getElementById("email-form").submit();
              """),
        ],
        .fragment(options(selectedEmail: email))
      ),
      .input()
    ),
    .div(
      attributes: [
        .class([Class.padding([.mobile: [.all: 2], .desktop: [.all: 4]])])
      ],
      email
        .flatMap(EmailTemplate.init(rawValue:))
        .map(email(selectedEmail:))
        ?? []
    ),
  ]
}

private func email(selectedEmail: EmailTemplate) -> Node {
  switch selectedEmail {
  case .welcomeEmail1:
    return welcomeEmail1Content(
      user: .init(
        email: "", episodeCreditCount: 1, gitHubUserId: 1, gitHubAccessToken: "", id: User.ID(),
        isAdmin: false, name: "Blob", referralCode: "", referrerId: User.ID(), rssSalt: "",
        subscriptionId: Subscription.ID()))
  case .welcomeEmail2:
    return []
  case .welcomeEmail3:
    return []
  }
}

private func options(selectedEmail: String?) -> [ChildOf<Tag.Select>] {
  var options = EmailTemplate.allCases.map { template in
    ChildOf<Tag.Select>.option(
      attributes: [
        .selected(template.rawValue == selectedEmail)
      ],
      template.rawValue
    )
  }
  options.prepend(.init(arrayLiteral: .option(attributes: [], "None")))
  return options
}
