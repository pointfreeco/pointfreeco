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

  return emails.flatMap(map(delayedSend) >>> sequence)
    .flatMap { results in
      sendEmail(
        to: adminEmails,
        subject: "Welcome emails sent",
        content: inj1("\(results.count) welcome emails sent")
      )
    }
    .map(const(unit))
}

func welcomeEmail1(_ user: Database.User) -> Email {
  return prepareEmail(
    to: [user.email],
    subject: "TODO",
    content: inj2(
      []
    )
  )
}

func welcomeEmail2(_ user: Database.User) -> Email {
  return prepareEmail(
    to: [user.email],
    subject: "TODO",
    content: inj2(
      []
    )
  )
}

func welcomeEmail3(_ user: Database.User) -> Email {
  return prepareEmail(
    to: [user.email],
    subject: "TODO",
    content: inj2(
      []
    )
  )
}
