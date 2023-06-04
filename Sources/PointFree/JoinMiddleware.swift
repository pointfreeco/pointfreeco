import Css
import Dependencies
import Either
import EmailAddress
import Foundation
import FunctionalCss
import Html
import HttpPipeline
import Models
import PointFreeRouter
import Stripe
import Styleguide
import Tagged
import URLRouting
import Views

func joinMiddleware(_ conn: Conn<StatusLineOpen, Join>) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.envVars.appSecret) var appSecret
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.date.now) var now
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
      let (decryptedCode, decryptedUserID, timestamp) = try? JoinSecretConversion().apply(secret),
      Int(now.timeIntervalSince1970) <= timestamp + 604_800,
      decryptedCode == code,
      decryptedUserID == currentUser.id
    else {
      return
        conn
        .redirect(to: .home) {
          $0.flash(.error, "This invite link is no longer valid")
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
            secret: try JoinSecretConversion().unapply(
              (code, currentUser.id, Int(now.timeIntervalSince1970))
            )
          )
        )
      )
      try await sendConfirmationEmail(email: email, code: code, currentUser: currentUser)
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

  func apply(
    _ input: Encrypted<String>
  ) throws -> (Models.Subscription.TeamInviteCode, User.ID, Int) {
    guard
      let parts = input.decrypt(with: appSecret)?.components(separatedBy: Self.separator),
      parts.count == 3,
      let timestamp = Int(parts[2]),
      let decryptedUserID = UUID(uuidString: String(parts[1]))
    else {
      throw ValidationError()
    }
    return (
      Models.Subscription.TeamInviteCode(String(parts[0])),
      User.ID(decryptedUserID),
      timestamp
    )
  }

  func unapply(
    _ output: (Models.Subscription.TeamInviteCode, User.ID, Int)
  ) throws -> Encrypted<String> {
    guard
      let encrypted = Encrypted(
        """
        \(output.0.rawValue)\(Self.separator)\(output.1.uuidString)\(Self.separator)\(output.2)
        """,
        with: appSecret
      )
    else {
      throw ValidationError()
    }
    return encrypted
  }
}

private func sendConfirmationEmail(
  email: EmailAddress,
  code: Models.Subscription.TeamInviteCode,
  currentUser: User
) async throws {
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  let confirmURL = siteRouter.url(
    for: .join(
      .confirm(
        code: code,
        secret: try JoinSecretConversion().unapply(
          (code, currentUser.id, Int(now.timeIntervalSince1970))
        )
      )
    )
  )

  try await sendEmail(
    to: [email],
    subject: "Confirm your email to join the Point-Free team subscription.",
    content: inj2(
      _simpleEmailLayout(
        SimpleEmailLayoutData(
          user: currentUser,
          newsletter: nil,
          title: "Confirm your email",
          preheader: "Confirm your email to join the Point-Free team subscription.",
          template: .default(includeHeaderImage: false),
          data: ()
        )
      ) {
        .emailTable(
          attributes: [.style(contentTableStyles)],
          .tr(
            .td(
              attributes: [.valign(.top)],
              .div(
                attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
                .h3(
                  attributes: [.class([Class.pf.type.responsiveTitle3])], "You’re invited!"),
                .markdownBlock(
                  attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
                  """
                  You’re invited to join the \(code.rawValue) team on [Point-Free](http://pointfree.co), a video
                  series about advanced concepts in the Swift programming language. To accept,
                  simply click the link below!
                  """),
                .p(
                  attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
                  .a(
                    attributes: [
                      .href(confirmURL),
                      .class([Class.pf.components.button(color: .purple)]),
                    ],
                    "Click here to accept!"
                  )
                )
              )
            )
          )
        )
      }
    )
  )
}

func _simpleEmailLayout(_ data: SimpleEmailLayoutData<Void>, body: @escaping () -> Node) -> Node {
  simpleEmailLayout(body)(data)
}
