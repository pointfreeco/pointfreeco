import EmailAddress
import GitHub
import Models
import StyleguideV2

public struct GitHubFailureView: HTML {
  let accessToken: AccessToken
  let email: EmailAddress
  let existingGitHubUser: GitHubUser
  let newGitHubUser: GitHubUser
  let redirect: String?

  public init(
    accessToken: AccessToken,
    email: EmailAddress,
    existingGitHubUser: GitHubUser,
    newGitHubUser: GitHubUser,
    redirect: String?
  ) {
    self.accessToken = accessToken
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
          While logging into your account we detected a problem. The primary email address 
          associated with your GitHub account, \(email), is already registered with Point-Free 
          under a different [GitHub account](http://github.com/\(existingGitHubUser.login)).
          
          Would you like to update your Point-Free account to use this 
          [GitHub account](http://github.com/\(newGitHubUser.login)) instead?
          """
        }

        HStack(alignment: .center) {
          Button(color: .purple) {
            "Update GitHub account"
          }
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

//The primary email address associated with your GitHub account, \(error.email.rawValue), is \
//already registered with Point-Free under a different \
//[GitHub account](https://github.com/settings) account.
//
//                 Log into the GitHub account associated with your Point-Free account before trying again, \
//                 or contact <support@pointfree.co>.
