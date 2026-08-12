import Dependencies
import EmailAddress
import GitHub
import Models
import PointFreeRouter
import StyleguideV2

public struct LinkGitHubView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let email: EmailAddress
  let newGitHubUser: GitHubUser
  let redirect: String?

  public init(
    email: EmailAddress,
    newGitHubUser: GitHubUser,
    redirect: String?
  ) {
    self.email = email
    self.newGitHubUser = newGitHubUser
    self.redirect = redirect
  }

  public var body: some HTML {
    PageHeader(title: "Link your GitHub account?") {
    }

    PageModule(theme: .content) {
      VStack(spacing: 2) {
        HTMLMarkdown {
          """
          You logged in with the GitHub account
          **[@\(newGitHubUser.login)](http://github.com/\(newGitHubUser.login))**, which has a
          primary email address **\(email)**. That email is already registered on Point-Free, but
          this is the first time it has been used to log in with GitHub.

          Would you like to link
          **[@\(newGitHubUser.login)](http://github.com/\(newGitHubUser.login))** to your existing
          Point-Free account? Going forward you will be able to log in with your email or GitHub.
          """
        }

        HStack(alignment: .center) {
          form {
            Button(tag: "input", color: .purple)
              .attribute("value", "Link @\(newGitHubUser.login) to my account")
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
    .linkStyle(LinkStyle(color: .offBlack.dark(.offWhite), underline: true))
  }
}
