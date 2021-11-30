import Either
import EmailAddress
import Html
import Mailgun
import Models
import PointFreeRouter
import Prelude

public func sendNewSubscriberWelcomeEmails() -> EitherIO<Error, Prelude.Unit> {
  let emails = Current.database.fetchNewSubscribersToWelcome()
    .map(map(welcomeSubscriberEmail))
    .debug { "📧: Sending \($0.count) new subscriber welcome emails..." }

    
  fatalError()
}

private func welcomeSubscriberEmail(_ user: User) -> Email {
  let subject = "?????????"
  return prepareWelcomeEmail(
    to: user,
    subject: subject,
    content: welcomeEmailView(subject, welcomeSubscriberEmailContent)
  )
}

private func welcomeSubscriberEmailContent(user: User) -> Node {
  return [
    .markdownBlock(
      """
      👋 Howdy!
      
      It's been a week since you signed up for [Point-Free](\(url(to: .home))). We hope you've learned
      something new about functional programming, and maybe even introduced it into your codebase!
      
      We'd love to [have you as a subscriber](\(url(to: .pricingLanding))), so please let us know if
      you have any questions. Just reply to this email!
      """
    ),
    user.episodeCreditCount > 0
    ? .markdownBlock(
        """
        In the meantime, it looks like you have a **free episode credit**! You can use this to see *any*
        subscriber-only episode, completely for free! Just visit [our site](\(url(to: .home))), go to an
        episode, and click the XXXXX button!
        
        Here are some of our most popular collections of episodes:
        
        * [Composable Architecture](https://www.pointfree.co/collections/composable-architecture)
        * [SwiftUI](https://www.pointfree.co/collections/swiftui)
        * [Dependencies](https://www.pointfree.co/collections/dependencies)
        * [Parsing](https://www.pointfree.co/collections/parsing)
        """
    )
    : []
    ,
    .markdownBlock(
      """
      When you're ready to subscribe for yourself _or_ your team, visit
      [our subscribe page](\(url(to: .pricingLanding)))!
      """
    ),
    hostSignOffView
  ]
}
