import Either
import Mailgun
import Models
import PointFreePrelude
import Prelude

public func validateEnterpriseEmails() -> EitherIO<Error, Prelude.Unit> {

  return Current.database.fetchEnterpriseEmails()
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

  return Current.mailgun.validate(enterpriseEmail.email)
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

  guard !validation.mailboxVerification else { return pure(unit) }

  return Current.database.fetchUserById(enterpriseEmail.userId)
    .mapExcept(requireSome)
    .flatMap { user in unlinkSubscription(enterpriseEmail: enterpriseEmail, user: user) }
}

private func unlinkSubscription(
  enterpriseEmail: EnterpriseEmail,
  user: Models.User
  ) -> EitherIO<Error, Prelude.Unit> {

  return Current.database.deleteEnterpriseEmail(enterpriseEmail)
    .flatMap { _ -> EitherIO<Error, Prelude.Unit> in
      guard let subscriptionId = user.subscriptionId else { return pure(unit) }

      return Current.database.removeTeammateUserIdFromSubscriptionId(user.id, subscriptionId)
        .catch(notifyAdmins(subject: "Couldn't remove subscription from user: \(enterpriseEmail.userId)"))
    }
    .flatMap { _ in notifyUserSubscriptionWasRemoved(user: user, enterpriseEmail: enterpriseEmail) }
}

private func notifyUserSubscriptionWasRemoved(
  user: Models.User,
  enterpriseEmail: EnterpriseEmail
  ) -> EitherIO<Error, Prelude.Unit> {

  guard let subscriptionId = user.subscriptionId else { return pure(unit) }

  return Current.database.fetchEnterpriseAccountForSubscription(subscriptionId)
    .mapExcept(requireSome)
    .flatMap { enterpriseAccount in
      sendEmail(
        to: [user.email],
        subject: "You have been removed from \(enterpriseAccount.companyName)’s Point-Free team",
        content: inj2(youHaveBeenRemovedEmailView.view(.enterpriseAccount(enterpriseAccount)))
        )
        .map(const(unit))
  }
}

private func sendValidationSummaryEmail(results: [ValidationResult]) -> EitherIO<Error, Prelude.Unit> {
  fatalError()
}

private enum ValidationResult {
  case invalidAndRemoved
  case valid
  case unknown
}
