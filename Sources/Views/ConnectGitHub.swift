import Dependencies
import GitHub
import Models
import PointFreeRouter
import StyleguideV2

public struct ConnectGitHubView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let state: State
  let redirect: String?

  public enum State {
    case ask
    case confirm(newGitHubUser: GitHubUser)
    case conflict(newGitHubUser: GitHubUser)
  }

  public init(
    state: State,
    redirect: String?
  ) {
    self.state = state
    self.redirect = redirect
  }

  public var body: some HTML {
    switch state {
    case .ask:
      ask
    case .confirm(let newGitHubUser):
      confirm(newGitHubUser: newGitHubUser)
    case .conflict(let newGitHubUser):
      conflict(newGitHubUser: newGitHubUser)
    }
  }

  private var ask: some HTML {
    HTMLGroup {
      PageHeader(title: "Connect your GitHub account") {
      }

      PageModule(theme: .content) {
        VStack(spacing: 2) {
          HTMLMarkdown {
            """
            Your Point-Free account isn’t connected to a GitHub account yet. Some features,
            such as beta previews, are managed through private GitHub repositories, so a
            connected GitHub account is required to continue.

            Once connected you will also be able to log in to Point-Free with GitHub.
            """
          }

          HStack(alignment: .center) {
            Button(color: .purple) {
              Label("Connect with GitHub", icon: .gitHubIcon)
                .fontStyle(.body(.regular))
            }
            .attribute(
              "href",
              siteRouter.path(for: .auth(.gitHubAuth(redirect: redirect)))
            )

            Link(href: "mailto:support@pointfree.co") {
              "Contact support"
            }
          }
        }
      }
      .linkStyle(LinkStyle(color: .offBlack.dark(.offWhite), underline: true))
    }
  }

  private func confirm(newGitHubUser: GitHubUser) -> some HTML {
    HTMLGroup {
      PageHeader(title: "Connect your GitHub account?") {
      }

      PageModule(theme: .content) {
        VStack(spacing: 2) {
          HTMLMarkdown {
            """
            You authenticated with the GitHub account
            **[@\(newGitHubUser.login)](http://github.com/\(newGitHubUser.login))**. Would you
            like to connect it to your Point-Free account? Once connected you will be able to
            log in with GitHub and join beta previews.
            """
          }

          HStack(alignment: .center) {
            form {
              Button(tag: "input", color: .purple)
                .attribute("value", "Connect @\(newGitHubUser.login)")
                .attribute("type", "submit")
            }
            .attribute(
              "action",
              siteRouter.path(
                for: .auth(.connectGitHub(redirect: redirect))
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

  private func conflict(newGitHubUser: GitHubUser) -> some HTML {
    HTMLGroup {
      PageHeader(title: "GitHub connection problem :(") {
      }

      PageModule(theme: .content) {
        VStack(spacing: 2) {
          HTMLMarkdown {
            """
            The GitHub account
            **[@\(newGitHubUser.login)](http://github.com/\(newGitHubUser.login))** is already
            connected to a different Point-Free account, so it cannot be connected to this one.
            If you think this is a mistake, please contact us at
            [support@pointfree.co](mailto:support@pointfree.co) and we will get it sorted out.
            """
          }
        }
      }
      .linkStyle(LinkStyle(color: .offBlack.dark(.offWhite), underline: true))
    }
  }
}
