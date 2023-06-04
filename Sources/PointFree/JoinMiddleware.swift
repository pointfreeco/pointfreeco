import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Stripe
import Tagged
import URLRouting
import Views

func joinMiddleware(_ conn: Conn<StatusLineOpen, Join>) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.envVars.appSecret) var appSecret
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.siteRouter) var siteRouter

  switch conn.data {
  case let .confirm(code: code, secret: secret):
    guard let currentUser = currentUser
    else {
      return
        await conn
        .redirect(to: siteRouter.loginPath(redirect: .join(.confirm(code: code, secret: secret))))
    }

    guard
      let (decryptedCode, decryptedUserID) = try? JoinSecretConversion().apply(secret),
      decryptedCode == code,
      decryptedUserID == currentUser.id
    else {
      return
        conn
        .redirect(to: .home) {
          $0.flash(.warning, "The invite link provided is no longer valid")
        }
    }

    return await add(currentUser: currentUser, code: code, conn: conn)

  case let .join(code: code, email: email):
    guard let currentUser = currentUser
    else {
      return
        conn
        .redirect(to: .join(.landing(code: code))) {
          $0.flash(.notice, "You must be logged in to complete that action.")
        }
    }

    guard let email = email
    else {
      return await add(currentUser: currentUser, code: code, conn: conn)
    }

    guard
      code.isDomain,
      let domain = email.split(separator: "@").last.map(String.init),
      code.rawValue.lowercased() == domain.lowercased()
    else {
      return
        conn
        .redirect(to: .join(.landing(code: code))) {
          $0.flash(
            .error,
            "Your email address must be from the @\(code) domain."
          )
        }
    }

    await fireAndForget {
      let url = siteRouter.url(
        for: .join(
          .confirm(
            code: code,
            secret: try JoinSecretConversion().unapply((code, currentUser.id))
          )
        )
      )
      try await sendEmail(
        to: [email],
        subject: "Confirm your email to join the Point-Free team subscription.",
        content: .left(
          """
          \(url)
          """)  // TODO: real email
      )
    }
    return
      conn
      .redirect(to: .home) {
        $0.flash(.notice, "Confirmation email sent to \(email.rawValue).")
      }

  case let .landing(code):
    guard
      let subscription = try? await database.fetchSubscriptionByTeamInviteCode(code),
      subscription.stripeSubscriptionStatus.isActive
    else {
      return
        conn
        .redirect(to: .home) {
          $0.flash(
            .error,
            "Cannot join team as it is inactive. Contact the subscription owner to re-activate."
          )
        }
    }

    return
      conn
      .writeStatus(.ok)
      .respond(view: joinTeamLanding(code:)) { _ in
        SimplePageLayoutData(
          data: code,
          title: "Join team subscription"
        )
      }
  }
}

private func add<A>(
  currentUser: User,
  code: Models.Subscription.TeamInviteCode,
  conn: Conn<StatusLineOpen, A>
) async -> Conn<ResponseEnded, Data> {
  // TODO: validate isTeamInviteCodeEnabled
  @Dependency(\.database) var database
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.stripe) var stripe

  let subscription: Models.Subscription
  do {
    subscription = try await database.fetchSubscriptionByTeamInviteCode(code)
  } catch {
    return
      conn
      .redirect(to: .home) {
        $0.flash(.error, "Could not find that team.")
      }
  }

  guard subscription.stripeSubscriptionStatus.isActive
  else {
    return
      conn
      .redirect(to: .join(.landing(code: code))) {
        $0.flash(
          .error,
          "Cannot join team as it is inactive. Contact the subscription owner to re-activate."
        )
      }
  }

  if let subscriptionID = currentUser.subscriptionId,
    let currentUserSubscription = try? await database.fetchSubscriptionById(subscriptionID),
    currentUserSubscription.stripeSubscriptionStatus.isActive
  {
    return
      conn
      .redirect(to: siteRouter.loginPath(redirect: .home)) {
        $0.flash(
          .warning,
          "You cannot join this team as you already have an active subscription."
        )
      }
  }

  let owner: User
  do {
    owner = try await database.fetchUserById(subscription.userId)
  } catch {
    return
      conn
      .redirect(to: .join(.landing(code: code))) {
        $0.flash(.error, "Cannot join team.")
      }
  }

  let stripeSubscription: Stripe.Subscription
  do {
    stripeSubscription = try await stripe.fetchSubscription(subscription.stripeSubscriptionId)
  } catch {
    return
      conn
      .redirect(to: .join(.landing(code: code))) {
        $0.flash(.error, "Could not find subscription. Try again or contact support@pointfree.co.")
      }
  }

  let newPricing = Pricing(
    billing: stripeSubscription.plan.interval == .month ? .monthly : .yearly,
    quantity: stripeSubscription.quantity + 1
  )
  do {
    let teammatesCount = try await database.fetchSubscriptionTeammatesByOwnerId(owner.id).count
    let invitesCount = try await database.fetchTeamInvites(owner.id).count
    let ownerSeatCount = owner.subscriptionId == subscription.id ? 1 : 0
    // TODO: send admin email if this condition is strictly greater than?
    if teammatesCount + invitesCount + ownerSeatCount >= stripeSubscription.quantity {
      _ = try await stripe.updateSubscription(
        stripeSubscription,
        newPricing.billing.plan,
        newPricing.quantity
      )
    }
    try await database.addUserIdToSubscriptionId(currentUser.id, subscription.id)
  } catch {
    return
      conn
      .redirect(to: .join(.landing(code: code))) {
        $0.flash(
          .error,
          "Could not add you to the team. Try again or contact support@pointfree.co."
        )
      }
  }
  await fireAndForget {
    _ = try? await sendEmail(
      to: [owner.email],
      subject: """
        \(currentUser.name ?? currentUser.email.rawValue) has joined your Point-Free subscription
        """,
      content: .left("Hello")  // TODO: real email
    )
    _ = try? await sendEmail(
      to: [currentUser.email],
      subject: """
        You have joined \(owner.name ?? owner.email.rawValue)'s Point-Free subscription
        """,
      content: .left("Hello")  // TODO: real email
    )
  }

  return
    conn
    .redirect(to: .account()) {
      $0.flash(.notice, "You now have access to Point-Free!")
    }
}

struct JoinSecretConversion: Conversion {
  private static let separator = "--{SEPARATOR}--"
  struct ValidationError: Error {}
  @Dependency(\.envVars.appSecret) var appSecret

  func apply(_ input: Encrypted<String>) throws -> (Models.Subscription.TeamInviteCode, User.ID) {
    guard
      let parts = input.decrypt(with: appSecret)?.components(separatedBy: Self.separator),
      parts.count == 2,
      let decryptedCode = parts.first.map({ Models.Subscription.TeamInviteCode(String($0)) }),
      let decryptedUserID = parts.last.flatMap({ UUID(uuidString: String($0)) })
    else {
      throw ValidationError()
    }
    return (decryptedCode, User.ID(decryptedUserID))
  }

  func unapply(
    _ output: (Models.Subscription.TeamInviteCode, User.ID)
  ) throws -> Encrypted<String> {
    guard
      let encrypted = Encrypted(
        """
        \(output.0.rawValue)\(Self.separator)\(output.1.uuidString)
        """,
        with: appSecret
      )
    else {
      throw ValidationError()
    }
    return encrypted
  }
}
