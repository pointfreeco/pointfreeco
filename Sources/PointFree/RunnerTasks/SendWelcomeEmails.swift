import Dependencies
import Either
import EmailAddress
import FunctionalCss
import Html
import HtmlCssSupport
import IssueReporting
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import StyleguideV2
import Views

public func sendWelcomeEmails() async throws {
  @Dependency(\.continuousClock) var clock
  @Dependency(\.database) var database

  await notifyError("Welcome emails failed") {
    async let emails1 = database.fetchUsersToWelcome(registeredWeeksAgo: 1).map(welcomeEmail1)
    async let emails2 = database.fetchUsersToWelcome(registeredWeeksAgo: 2).map(welcomeEmail2)
    async let users3 = database.fetchUsersToWelcome(registeredWeeksAgo: 3)
    let emails3 = try await users3.map(welcomeEmail3)
    if try await !users3.isEmpty {
      _ = try await database.incrementEpisodeCredits(userIDs: users3.map(\.id))
    }

    let emails = try await emails1 + emails2 + emails3
    print("📧: Sending \(emails.count) welcome emails...")
    var sentEmails: [SendEmailResponse] = []
    for email in emails {
      try await withRetries(3) {
        try await sentEmails.append(send(email: email))
      } backoff: { _ in
        .seconds(10)
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

func welcomeEmail1(_ user: User) -> Email {
  return prepareEmailV2(
    to: [user.email],
    subject: "Thanks for signing up to Point-Free!",
    unsubscribeData: (user.id, .welcomeEmails),
    content: WelcomeEmail(
      preheader: user.episodeCreditCount > 0 ? """
        Use your episode credit to unlock any subscriber-only episode!
        """ : """
        Explore our most popular episodes and join our vibrant Slack community!
        """
    ) {
      WelcomeEmailWeek1(user: user)
    }
  )
}

func welcomeEmail2(_ user: User) -> Email {
  @Dependency(\.episodes) var episodes
  let freeEpisodeCount = episodes().count(where: { $0.subscriberOnly })
  return prepareEmailV2(
    to: [user.email],
    subject: "Free episodes on Point-Free",
    unsubscribeData: (user.id, .welcomeEmails),
    content: WelcomeEmail(
      preheader: """
        Explore our \(freeEpisodeCount) free episodes!
        """
    ) {
      WelcomeEmailWeek2(user: user)
    }
  )
}

func welcomeEmail3(_ user: User) -> Email {
  return prepareEmailV2(
    to: [user.email],
    subject: "Here's a free episode!",
    unsubscribeData: (user.id, .welcomeEmails),
    content: WelcomeEmail(
      preheader: """
        Level up your engineering skills with a subscription to Point-Free.
        """
    ) {
      WelcomeEmailWeek3(user: user)
    }
  )
}

private func withRetries<R>(
  _ attempts: Int,
  operation: () async throws -> R,
  backoff: (Int) -> Duration = { _ in .seconds(0) }
) async throws -> R {
  @Dependency(\.continuousClock) var clock
  for attempt in 1...attempts {
    do {
      return try await operation()
    } catch  where attempt < attempts {
      try await clock.sleep(for: backoff(attempt))
    }
  }
  throw CancellationError()
}
