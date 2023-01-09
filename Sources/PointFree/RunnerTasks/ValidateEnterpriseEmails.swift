import Dependencies
import Either
import Mailgun
import Models
import PointFreePrelude
import Prelude

public func validateEnterpriseEmails() -> EitherIO<Error, Prelude.Unit> {
  @Dependency(\.database) var database

  // TODO: calendar check for first of the month

  return EitherIO { try await database.fetchEnterpriseEmails() }
    .flatMap(validate(enterpriseEmails:))
    .flatMap(sendValidationSummaryEmail(results:))
}

private func validate(enterpriseEmails: [EnterpriseEmail]) -> EitherIO<Error, [ValidationResult]> {
  return lift(
    sequence(
      enterpriseEmails
        .map(validate(enterpriseEmail:))
    )
    .sequential
  )
}

private func validate(enterpriseEmail: EnterpriseEmail) -> Parallel<ValidationResult> {
  @Dependency(\.mailgun) var mailgun

  return EitherIO { try await mailgun.validate(enterpriseEmail.email) }
    .flatMap { validation in
      validateSubscription(validation: validation, enterpriseEmail: enterpriseEmail)
        .map(const(validation))
    }
    .map { $0.mailboxVerification ? ValidationResult.valid : .invalidAndRemoved }
    .catch(const(pure(.unknown)))
    .run
    .map { $0.right ?? .unknown }
    .parallel
}

private func validateSubscription(
  validation: Mailgun.Client.Validation,
  enterpriseEmail: EnterpriseEmail
) -> EitherIO<Error, Prelude.Unit> {
  @Dependency(\.database) var database

  guard !validation.mailboxVerification else { return pure(unit) }

  return EitherIO { try await database.fetchUserById(enterpriseEmail.userId) }
    .flatMap { user in unlinkSubscription(enterpriseEmail: enterpriseEmail, user: user) }
}

private func unlinkSubscription(
  enterpriseEmail: EnterpriseEmail,
  user: Models.User
) -> EitherIO<Error, Prelude.Unit> {
  @Dependency(\.database) var database

  return EitherIO {
    try await database.deleteEnterpriseEmail(enterpriseEmail.userId)
    guard let subscriptionId = user.subscriptionId else { return }
    try await database.removeTeammateUserIdFromSubscriptionId(user.id, subscriptionId)
  }
  .mapExcept(const(pure(unit)))
  .catch(
    notifyAdmins(subject: "Couldn't remove subscription from user: \(enterpriseEmail.userId)")
  )
  .flatMap { _ in notifyUserSubscriptionWasRemoved(user: user, enterpriseEmail: enterpriseEmail) }
}

private func notifyUserSubscriptionWasRemoved(
  user: Models.User,
  enterpriseEmail: EnterpriseEmail
) -> EitherIO<Error, Prelude.Unit> {
  @Dependency(\.database) var database

  guard let subscriptionId = user.subscriptionId else { return pure(unit) }

  return EitherIO {
    try await database.fetchEnterpriseAccountForSubscription(subscriptionId)
  }
  .flatMap { enterpriseAccount in
    EitherIO {
      _ = try await sendEmail(
        to: [user.email],
        subject: "You have been removed from \(enterpriseAccount.companyName)’s Point-Free team",
        content: inj2(youHaveBeenRemovedEmailView(.enterpriseAccount(enterpriseAccount)))
      )
      return unit
    }
  }
}

private func sendValidationSummaryEmail(results: [ValidationResult]) -> EitherIO<
  Error, Prelude.Unit
> {

  // TODO: send admin email
  return pure(unit)
}

private enum ValidationResult {
  case invalidAndRemoved
  case valid
  case unknown
}
