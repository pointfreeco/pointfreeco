import Either
import Html
import Prelude

public func sendWelcomeEmails() -> EitherIO<Error, Prelude.Unit> {
  let emails = EitherIO(
    run: concat([
      Current.database.fetchUsersToWelcome(1)
        .map(map(welcomeEmail1))
        .run.parallel,
      Current.database.fetchUsersToWelcome(2)
        .map(map(welcomeEmail2))
        .run.parallel,
      Current.database.fetchUsersToWelcome(3)
        .map(map(welcomeEmail3))
        .run.parallel
      ])
    .sequential
  )

  let delayedSend = send(email:)
    >>> delay(.milliseconds(200))
    >>> retry(maxRetries: 3, backoff: { .seconds(10 * $0) })

  return emails
    .flatMap(map(delayedSend) >>> sequence)
    .flatMap { results in
      sendEmail(
        to: adminEmails,
        subject: "Welcome emails sent",
        content: inj1("\(results.count) welcome emails sent")
      )
    }
    .map(const(unit))
}

// TODO: team callouts

func welcomeEmail1(_ user: Database.User) -> Email {
  return prepareEmail(
    to: [user.email],
    subject: "Thanks for signing up to Point-Free",
    content: inj2(
      [
Html.text <| """
It's been a week since you signed up for your Point-Free account. We hope you've learned something
new about functional programming, and maybe even introduced it into your codebase!

We'd love to have you as a subscriber, so please let us know if you have any questions. Just reply to this
email!

In the meantime, remember that you have a credit you can use to see *any* subscriber-only
episode, completely for free. Just visit our site, go to an episode, and click the "\(useCreditCTA)"
button!
"""
      ]
    )
  )
}

func welcomeEmail2(_ user: Database.User) -> Email {
  return prepareEmail(
    to: [user.email],
    subject: "Free episodes on Point-Free",
    content: inj2(
      [
"""
Hey there! You signed up for a Point-Free account two weeks ago, but haven't subscribed yet.

[list of free episodes]
"""
      ]
    )
  )
}

func welcomeEmail3(_ user: Database.User) -> Email {
  return prepareEmail(
    to: [user.email],
    subject: "Still undecided? How about a free episode?",
    content: inj2(
      [
"""
Hiya! This will be the last email from us. We just wanted to reach out one more time to give you another
free episode credit. Please use it to check out another subscriber-only episode completely free. We hope
you'll find it interesting enough to consider a subscription.

Speaking of subscriptions, we support both individual and team subscriptions.

Some of our personal favorite episodes are:

* Contravariance
* Tagged
* Setters
* NonEmpty
"""
      ]
    )
  )
}
