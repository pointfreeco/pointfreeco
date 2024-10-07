import Dependencies
import EmailAddress
import GitHub
import Models
import PointFreeRouter
import StyleguideV2

public struct GitHubFailureView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let email: EmailAddress
  let existingGitHubUser: GitHubUser
  let newGitHubUser: GitHubUser
  let redirect: String?

  public init(
    email: EmailAddress,
    existingGitHubUser: GitHubUser,
    newGitHubUser: GitHubUser,
    redirect: String?
  ) {
    self.email = email
    self.existingGitHubUser = existingGitHubUser
    self.newGitHubUser = newGitHubUser
    self.redirect = redirect
  }

  public var body: some HTML {
    PageHeader(title: "GitHub login problem :(") {
    }

    PageModule(theme: .content) {
      VStack(spacing: 2) {
        HTMLMarkdown {
          """
          While logging into your account we detected a problem. You logged in with the GitHub
          account **[@\(newGitHubUser.login)](http://github.com/\(newGitHubUser.login))** 
          which has a primary email address **\(email)**. However, that email was already registered
          on Point-Free under the GitHub account
          **[@\(existingGitHubUser.login)](http://github.com/\(existingGitHubUser.login))**.

          Would you like to update your Point-Free account to use the GitHub account
          **[@\(newGitHubUser.login)](http://github.com/\(newGitHubUser.login))** instead?
          """
        }

        HStack(alignment: .center) {
          form {
            Button(tag: "input", color: .purple)
              .attribute("value", "Use @\(newGitHubUser.login) for login")
              .attribute("type", "submit")
          }
          .attribute(
            "action",
            siteRouter.path(
              for: .auth(.updateGitHub(redirect: redirect))
            )
          )
          .attribute("method", "post")

          Link(href: "mailto:support@pointfree.co") {
            "Contact support"
          }
        }
      }
    }
    .color(.offBlack.dark(.offWhite))
    .linkStyle(LinkStyle(color: .offBlack.dark(.offWhite), underline: true))
  }
}
