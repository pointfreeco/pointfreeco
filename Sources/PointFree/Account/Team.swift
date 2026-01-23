import Dependencies
import Either
import Foundation
import HttpPipeline
import Models

func leaveTeamMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  currentUser: User?,
  subscriberState: SubscriberState
) async -> Conn<ResponseEnded, Data> {
  guard let currentUser else { return conn.loginAndRedirect() }
  guard !subscriberState.isOwner else {
    return conn.redirect(to: .account()) {
      $0.flash(.error, "You are the owner of the subscription, you can’t leave.")
    }
  }

  @Dependency(\.database) var database
  do {
    if let subscriptionId = currentUser.subscriptionId {
      try await database.removeTeammate(userID: currentUser.id, fromSubscriptionID: subscriptionId)
      try await database.deleteEnterpriseEmail(userID: currentUser.id)
    }
    return conn.redirect(to: .account()) {
      $0.flash(.notice, "You are no longer a part of that team.")
    }
  } catch {
    return conn.redirect(to: .account()) {
      $0.flash(.error, "Something went wrong. Please try again or contact <support@pointfree.co>.")
    }
  }
}

func joinTeamLandingMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  inviteCode: Subscription.TeamInviteCode
) -> Conn<ResponseEnded, Data> {
  conn.head(.ok)
}

func joinTeamMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  inviteCode: Subscription.TeamInviteCode
) -> Conn<ResponseEnded, Data> {
  conn.head(.ok)
}

func removeTeammateMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  teammateID: User.ID,
  currentUser: User?
) async -> Conn<ResponseEnded, Data> {
  guard let currentUser else { return conn.loginAndRedirect() }
  @Dependency(\.database) var database

  guard let teammate = try? await database.fetchUser(id: teammateID) else {
    return conn.redirect(to: .account()) {
      $0.flash(.error, "Could not find that teammate.")
    }
  }
  guard let teammateSubscriptionId = teammate.subscriptionId else {
    return conn.redirect(to: .account()) {
      $0.flash(.notice, "That teammate has been removed.")
    }
  }

  do {
    let subscription = try await database.fetchSubscription(id: teammateSubscriptionId)
    // Validate the current user is the subscription owner,
    // and the fetched user is in fact the current user's teammate.
    guard subscription.userId == currentUser.id && subscription.id == teammate.subscriptionId
    else { throw TeamError.unauthorized }

    try await database.removeTeammate(
      userID: teammate.id,
      fromSubscriptionID: teammateSubscriptionId
    )

    if currentUser.id != teammate.id {
      Task {
        try await sendEmail(
          to: [teammate.email],
          subject: "You have been removed from \(currentUser.displayName)’s Point-Free team",
          content: inj2(youHaveBeenRemovedEmailView(.teamOwner(currentUser)))
        )
      }
      Task {
        try await sendEmail(
          to: [currentUser.email],
          subject: "Your teammate \(teammate.displayName) has been removed",
          content: inj2(teammateRemovedEmailView((currentUser, teammate)))
        )
      }
    }
  } catch {
    // Swallow errors to match legacy behavior.
  }

  return conn.redirect(to: .account()) {
    $0.flash(.notice, "That teammate has been removed.")
  }
}

private enum TeamError: Error {
  case unauthorized
}
