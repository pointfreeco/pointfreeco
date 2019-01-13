import Either
import Html
import HtmlCssSupport
import Prelude
import Styleguide
import View

public func sendWelcomeEmails() -> EitherIO<Error, Prelude.Unit> {
  let zippedEmails = zip3(
      Current.database.fetchUsersToWelcome(1)
        .map(map(welcomeEmail1))
        .run.parallel,
      Current.database.fetchUsersToWelcome(2)
        .map(map(welcomeEmail2))
        .run.parallel,
      Current.database.fetchUsersToWelcome(3)
        .flatMap { users in Current.database.incrementEpisodeCredits(users.map(^\.id)) }
        .map(map(welcomeEmail3))
        .run.parallel
  )
  let flattenedEmails = zippedEmails
    .map { curry { $0 + $1 + $2 } <¢> $0 <*> $1 <*> $2 }
  let emails = EitherIO(run: flattenedEmails.sequential)

  let delayedSend = send(email:)
    >>> delay(.milliseconds(200))
    >>> retry(maxRetries: 3, backoff: { .seconds(10 * $0) })

  return emails
    .flatMap(map { email in delayedSend(email).map(const(email)) } >>> sequence)
    .flatMap { (emails: [Email]) -> EitherIO<Error, Mailgun.SendEmailResponse> in
      let stats = emails
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
      return sendEmail(
        to: adminEmails,
        subject: "Welcome emails sent",
        content: inj1("\(emails.count) welcome emails sent\n\n\(stats)")
      )
    }
    .map(const(unit))
    .catch(notifyError(subject: "Welcome emails failed"))
}

private func notifyError<A>(subject: String) -> (Error) -> EitherIO<Error, A> {
  return { error in
    var errorDump = ""
    dump(error, to: &errorDump)

    return sendEmail(
      to: adminEmails,
      subject: "[PointFree Error] \(subject)",
      content: inj1(errorDump)
      )
      .flatMap(const(throwE(error)))
  }
}

// TODO: team callouts

private func prepareWelcomeEmail(to user: Database.User, subject: String, content: View<Database.User>)
  -> Email {
    return prepareEmail(
      to: [user.email],
      subject: subject,
      content: inj2(content.view(user))
    )
}

func welcomeEmailView(_ subject: String, _ content: View<Database.User>) -> View<Database.User> {
  return simpleEmailLayout(content.map(wrapper)).contramap { user in
    SimpleEmailLayoutData(
      user: user,
      newsletter: .welcomeEmails,
      title: subject,
      preheader: "",
      template: .default,
      data: user
    )
  }
}

private let wrapper = { view in
  [
    emailTable([style(contentTableStyles)], [
      tr([
        td([valign(.top)], [
          div([`class`([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])], view)
          ])
        ])
      ])
  ]
}

func welcomeEmail1(_ user: Database.User) -> Email {
  let subject = "Thanks for signing up to Point-Free!"
  return prepareWelcomeEmail(
    to: user,
    subject: subject,
    content: welcomeEmailView(subject, welcomeEmail1Content)
  )
}

let welcomeEmail1Content = View<Database.User> { user -> [Node] in
  [
    markdownBlock(
      """
      👋 Howdy!

      It's been a week since you signed up for [Point-Free](\(url(to: .home))). We hope you've learned
      something new about functional programming, and maybe even introduced it into your codebase!

      We'd love to [have you as a subscriber](\(url(to: .pricing(nil, expand: nil)))), so please let us know if
      you have any questions. Just reply to this email!
      """
    ),
    user.episodeCreditCount > 0
      ? markdownBlock(
        """
        In the meantime, it looks like you have a **free episode credit**! You can use this to see *any*
        subscriber-only episode, completely for free! Just visit [our site](\(url(to: .home))), go to an
        episode, and click the "\(useCreditCTA)" button!

        Here are some of the top episodes that viewers have chosen to use their credits on:

        * [Dependency Injection Made Easy](https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy)
        * [Algebraic Data Type: Part 1](https://www.pointfree.co/episodes/ep4-algebraic-data-types)
        * [Tagged](https://www.pointfree.co/episodes/ep12-tagged)
        * [Contravariance](https://www.pointfree.co/episodes/ep14-contravariance)
        """
        )
      : nil
    ,
    markdownBlock(
      """
      When you're ready to subscribe for yourself _or_ your team, visit
      [our subscribe page](\(url(to: .pricing(nil, expand: nil))))!
      """
    ),
    subscribeButton,
    ]
    .compactMap(id)
    <> hostSignOffView.view(unit)
}

func welcomeEmail2(_ user: Database.User) -> Email {
  let subject = "Free episodes on Point-Free"
  return prepareWelcomeEmail(
    to: user,
    subject: subject,
    content: welcomeEmailView(subject, welcomeEmail2Content)
  )
}

let welcomeEmail2Content = View<Database.User> { user -> [Node] in
  let freeEpisodeLinks = Current.episodes()
    .sorted(by: their(^\.sequence, >))
    .filter { !$0.subscriberOnly }
    .map {
      """
      * [\($0.title)](\(url(to: .episode(.left($0.slug)))))
      """
    }
    .joined(separator: "\n")
  return [
    markdownBlock(
      """
      👋 Hey there!

      You signed up for a [Point-Free](\(url(to: .home))) account a couple weeks ago but still haven't subscribed!

      If you're still on the fence and want to see a little more of what we have to offer, we have a number
      of free episodes for you to check out!

      \(freeEpisodeLinks)
      """
    ),
    user.episodeCreditCount > 0
      ? markdownBlock(
        """
        You *also* have a **free episode credit** you can use to see *any* _subscriber-only_ episode,
        completely for free! Just visit [our site](\(url(to: .home))), go to an episode, and click the "\(useCreditCTA)" button.
        """
        )
      : nil
    ,
    markdownBlock(
      """
      If you have any questions, don't hesitate to reply to this email!

      When you're ready to subscribe for yourself _or_ your team, visit
      [our subscribe page](\(url(to: .pricing(nil, expand: nil))))!
      """
    ),
    subscribeButton,
    ]
    .compactMap(id)
    <> hostSignOffView.view(unit)
}

func welcomeEmail3(_ user: Database.User) -> Email {
  let subject = "Here's a free episode!"
  return prepareWelcomeEmail(
    to: user,
    subject: subject,
    content: welcomeEmailView(subject, welcomeEmail3Content)
  )
}

let welcomeEmail3Content = View<Database.User> { user -> [Node] in
  [
    markdownBlock(
      """
      👋 Hiya!

      We just wanted to reach out one last time in the hope that we might make a subscriber out of you yet,
      so we've given you another **free episode credit**.
      """
    ),
    user.episodeCreditCount > 1
      ? markdownBlock(
        """
        It looks like you may have been saving the last one for a rainy day! But now you have
        \(user.episodeCreditCount), so it's time to cash one in! 🤑
        """
        )
      : nil
    ,
    markdownBlock(
      """
      Please use it to check out _any_ subscriber-only episode, completely free! Just visit [our site](\(url(to: .home))), go to
      an episode, and click the "\(useCreditCTA)" button.

      If you're having trouble deciding on an episode, here are a few of our favorites:

      * [The Many Faces of Map](https://www.pointfree.co/episodes/ep13-the-many-faces-of-map)

        We take a tour of the `map` function and figure out just what makes it so special!

      * [Contravariance](https://www.pointfree.co/episodes/ep14-contravariance)

        A fun, mind-bendy episode that explores what it means to the take that `map` function and flip it
        around!

      * [Tagged](https://www.pointfree.co/episodes/ep12-tagged)

        This one's a bit more down-to-earth! We talk about type-safety and how Swift's type system gives us
        yet another powerful tool to prevent bugs _at compile time!_

      * [Setters: Part 1](https://www.pointfree.co/episodes/ep6-functional-setters)

        Setters are functions that make you rethink function composition in some pretty powerful ways! This is
        the first of a multi-part series that goes _deep!_

      We hope you'll find it interesting enough to consider
      [getting a subscription](\(url(to: .pricing(nil, expand: nil)))) for yourself or your team!
      """
    ),
    subscribeButton,
    ]
    .compactMap(id)
    <> hostSignOffView.view(unit)
}

private let subscribeButton = p(
  [`class`([Class.padding([.mobile: [.topBottom: 2]])])],
  [
    a([href(url(to: .pricing(nil, expand: nil))), `class`([Class.pf.components.button(color: .purple)])],
      ["Subscribe to Point-Free!"]
    ),
  ]
)
