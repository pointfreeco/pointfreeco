import Dependencies
import Either
import EmailAddress
import FunctionalCss
import Html
import HtmlCssSupport
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import Views

public func sendWelcomeEmails() async throws {
  @Dependency(\.continuousClock) var clock
  @Dependency(\.database) var database

  await notifyError(subject: "Welcome emails failed") {
    async let emails1 = database.fetchUsersToWelcome(1).map(welcomeEmail1)
    async let emails2 = database.fetchUsersToWelcome(2).map(welcomeEmail2)
    async let users = database.fetchUsersToWelcome(3)
    let emails3 = try await users.map(welcomeEmail3)
    if try await !users.isEmpty {
      _ = try await database.incrementEpisodeCredits(users.map(\.id))
    }

    let emails = try await emails1 + emails2 + emails3
    print("📧: Sending \(emails.count) welcome emails...")
    var sentEmails: [SendEmailResponse] = []
    for email in emails {
      for attempt in 1...3 {
        do {
          try await sentEmails.append(send(email: email))
          try await clock.sleep(for: .milliseconds(200))
          break
        } catch  where attempt < 3 {
          try await clock.sleep(for: .seconds(10))
        }
      }
    }

    let stats =
      emails
      .reduce(into: [String: [EmailAddress]]()) { dict, email in
        dict[email.subject, default: []].append(contentsOf: email.to)
      }
      .map { subject, emails in
        """
        \(emails.count) \"\(subject)\" emails
        \(emails.map { "  - " + $0.rawValue }.joined(separator: "\n"))
        """
      }
      .joined(separator: "\n\n")

    try await sendEmail(
      to: adminEmails,
      subject: "Welcome emails sent",
      content: inj1("\(emails.count) welcome emails sent\n\n\(stats)")
    )
  }
}

func notifyAdmins<A>(subject: String) -> (Error) -> EitherIO<Error, A> {
  return { error in
    EitherIO {
      var errorDump = ""
      dump(error, to: &errorDump)
      _ = try await sendEmail(
        to: adminEmails,
        subject: "[PointFree Error] \(subject)",
        content: inj1(errorDump)
      )
      throw error
    }
  }
}

// TODO: team callouts

private func prepareWelcomeEmail(to user: User, subject: String, content: (User) -> Node) -> Email {
  return prepareEmail(
    to: [user.email],
    subject: subject,
    content: inj2(content(user))
  )
}

func welcomeEmailView(_ subject: String, _ content: @escaping (User) -> Node) -> (User) -> Node {
  return simpleEmailLayout(content >>> wrapper) <<< { user in
    SimpleEmailLayoutData(
      user: user,
      newsletter: .welcomeEmails,
      title: subject,
      preheader: "",
      template: .default(),
      data: user
    )
  }
}

private func wrapper(view: Node) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])],
          view
        )
      )
    )
  )
}

func welcomeEmail1(_ user: User) -> Email {
  let subject = "Thanks for signing up to Point-Free!"
  return prepareWelcomeEmail(
    to: user,
    subject: subject,
    content: welcomeEmailView(subject, welcomeEmail1Content)
  )
}

func welcomeEmail1Content(user: User) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .markdownBlock(
      """
      👋 Howdy!

      It's been a week since you signed up for [Point-Free](\(siteRouter.url(for: .home))). We hope
      you've learned something new about functional programming, and maybe even introduced it into
      your codebase!

      We'd love to [have you as a subscriber](\(siteRouter.url(for: .pricingLanding))), so please
      let us know if you have any questions. Just reply to this email!
      """
    ),
    user.episodeCreditCount > 0
      ? .markdownBlock(
        """
        In the meantime, it looks like you have a **free episode credit**! You can use this to see
        *any* subscriber-only episode, completely for free! Just visit [our
        site](\(siteRouter.url(for: .home))), go to an episode, and click the "\(useCreditCTA)"
        button!

        Here are some of our most popular collections of episodes:

        * **[Composable
        Architecture](https://www.pointfree.co/collections/composable-architecture):** Learn how to
        build an architecture from the ground up, with a focus on ergnomics, composition, testing,
        and more.

        * **[SwiftUI](https://www.pointfree.co/collections/swiftui):** We dive deep into some of the
        subtler, more complex topics of SwiftUI, such as bindings, animation and navigation. We even
        have a series called [Modern
        SwiftUI](https://www.pointfree.co/collections/swiftui/modern-swiftui) where we demonstrate
        how to build a large, complex application from scratch using best, modern practices.

        * **[Dependencies](https://www.pointfree.co/collections/dependencies):** Dependencies can
        wreak havoc on a codebase. We take the time to properly define what a dependency is, why
        they are so complex, and how we can take control of them rather than letting them control
        us.

        * **[Parsing](https://www.pointfree.co/collections/parsing):** Parsing is the process of
        turning nebulous input data into well-structured output data. It's a surprisingly ubiquitous
        topic, and our episodes are the perfect place to get started.

        * **[And a whole lot more](https://www.pointfree.co/collections)…**
        """
      )
      : [],
    .markdownBlock(
      """
      We also have a vibrant [Point-Free Slack community](http://pointfree.co/slack-invite). Join
      today to discuss episodes with other community members, ask questions about our episodes
      or open source projects, and more!

      When you're ready to subscribe for yourself _or_ your team, visit [our subscribe
      page](\(siteRouter.url(for: .pricingLanding)))!
      """
    ),
    subscribeButton,
    hostSignOffView,
  ]
}

func welcomeEmail2(_ user: User) -> Email {
  let subject = "Free episodes on Point-Free"
  return prepareWelcomeEmail(
    to: user,
    subject: subject,
    content: welcomeEmailView(subject, welcomeEmail2Content)
  )
}

func welcomeEmail2Content(user: User) -> Node {
  @Dependency(\.episodes) var episodes
  @Dependency(\.siteRouter) var siteRouter

  let freeEpisodeLinks = episodes()
    .sorted(by: their(\.sequence, >))
    .filter { !$0.subscriberOnly }
    .map {
      """
      * [\($0.fullTitle)](\(siteRouter.url(for: .episode(.show(.left($0.slug))))))
      """
    }
    .joined(separator: "\n")

  return [
    .markdownBlock(
      """
      👋 Hey there!

      You signed up for a [Point-Free](\(siteRouter.url(for: .home))) account a couple weeks ago but
      still haven't subscribed!

      If you're still on the fence and want to see a little more of what we have to offer, we have a
      number of free episodes for you to check out!

      \(freeEpisodeLinks)
      """
    ),
    user.episodeCreditCount > 0
      ? .markdownBlock(
        """
        You *also* have a **free episode credit** you can use to see *any* _subscriber-only_
        episode, completely for free! Just visit [our site](\(siteRouter.url(for: .home))), go to
        an episode, and click the "\(useCreditCTA)" button.
        """
      )
      : [],
    .markdownBlock(
      """
      If you have any questions, don't hesitate to reply to this email!

      When you're ready to subscribe for yourself _or_ your team, visit
      [our subscribe page](\(siteRouter.url(for: .pricingLanding)))!
      """
    ),
    subscribeButton,
    hostSignOffView,
  ]
}

func welcomeEmail3(_ user: User) -> Email {
  let subject = "Here's a free episode!"
  return prepareWelcomeEmail(
    to: user,
    subject: subject,
    content: welcomeEmailView(subject, welcomeEmail3Content)
  )
}

func welcomeEmail3Content(user: User) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .markdownBlock(
      """
      👋 Hiya!

      We just wanted to reach out one last time in the hope that we might make a subscriber out of
      you yet, so we've given you another **free episode credit**.
      """
    ),
    user.episodeCreditCount > 1
      ? .markdownBlock(
        """
        It looks like you may have been saving the last one for a rainy day! But now you have
        \(user.episodeCreditCount), so it's time to cash one in! 🤑
        """
      )
      : [],
    .markdownBlock(
      """
      Please use it to check out _any_ subscriber-only episode, completely free! Just visit
      [our site](\(siteRouter.url(for: .home))), go to an episode, and click the "\(useCreditCTA)"
      button.

      If you're having trouble deciding on an episode, here are a few of our favorites:

      * **[Composable Architecture](https://www.pointfree.co/collections/composable-architecture):**
        Learn how to build an architecture from the ground up, with a focus on ergnomics,
      composition, testing, and more.

      * **[SwiftUI](https://www.pointfree.co/collections/swiftui)** We dive deep into some of the
      subtler, more complex topics of SwiftUI, such as bindings, animation and navigation.

      * **[Dependencies](https://www.pointfree.co/collections/dependencies):** Dependencies can
      wreak havoc on a codebase. We take the time to properly define what a dependency is, why they
      are so complex, and how we can take control of them rather than letting them control us.

      * **[Parsing](https://www.pointfree.co/collections/parsing):** Parsing is the process of
      turning nebulous input data into well-structured output data. It's a surprisingly ubiquitous
      topic, and our episodes are the perfect place to get started.

      * **[And a whole lot more](https://www.pointfree.co/collections)…**

      We hope you'll find it interesting enough to consider
      [getting a subscription](\(siteRouter.url(for: .pricingLanding))) for yourself or your team!
      """
    ),
    subscribeButton,
    hostSignOffView,
  ]
}

private var subscribeButton: Node {
  @Dependency(\.siteRouter) var siteRouter

  return .p(
    attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
    .a(
      attributes: [
        .href(siteRouter.url(for: .pricingLanding)),
        .class([Class.pf.components.button(color: .purple)]),
      ],
      "Subscribe to Point-Free!"
    )
  )
}
