import Either
import Mailgun
import Models
import PointFreePrelude
import Prelude

public func deliverGifts() -> EitherIO<Error, Prelude.Unit> {
  EitherIO { try await Current.database.fetchGiftsToDeliver() }
    .flatMap { gifts in
      sequence(
        gifts.map { gift in
          gift.stripePaymentIntentStatus == .succeeded
            ? sendGiftEmail(for: gift)
              .delay(.milliseconds(200))
              .retry(maxRetries: 3, backoff: { .seconds(10 * $0) })
              .flatMap { _ in
                EitherIO {
                  try await Current.database.updateGiftStatus(gift.id, .succeeded, true)
                }
              }
            : pure(gift)
        }
      )
    }
    .flatMap { gifts in
      EitherIO {
        _ = try await sendEmail(
          to: adminEmails,
          subject: "Gift emails sent",
          content: inj1("\(gifts.count) gift emails sent")
        )
        return unit
      }
    }
}
