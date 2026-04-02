import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

struct ProWelcomeEmail: EmailDocument {
  @Dependency(\.siteRouter) var siteRouter
  let user: User

  var body: some HTML {
    EmailLayout(user: user) {
      tr {
        td {
          EmailMarkdown {
            """
            ## Welcome to Point-Free!

            Hey \(user.displayName)! Thanks so much for becoming a Point-Free member. We're excited \
            to have you on board.

            Here's what you now have access to:

            * **All episodes and videos**: Our entire back catalog of episodes covering \
            advanced topics in Swift, the Composable Architecture, SwiftUI, and much more. Browse \ 
            all  [episodes](\(siteRouter.url(for: .episodes(.list(.all))))).

            * **The Point-Free Way**: A CLI tool that puts the principles from our videos into \ 
            practice for your AI agents. Check it out [here](\(siteRouter.url(for: .theWay))).

            * **Private podcast feed**: Listen to episodes on the go with your own private, \
            offline podcast feed. Set it up from \
            [your account](\(siteRouter.url(for: .account(.index)))).

            * **On-demand livestream access**: Watch our livestreams on demand, anytime.

            
            If you have any questions or feedback, don't hesitate to reach out at \
            [support@pointfree.co](mailto:support@pointfree.co).
            
            ---
            
            **Want even more Point-Free?** [Upgrade to \
            Max](\(siteRouter.url(for: .pricingLanding))) for access to \
            [beta previews](\(siteRouter.url(for: .betas(.landing)))) of our libraries and private \
            office hour livestreams.
            
            ---
            """
          }
        }
      }
    }
  }
}
