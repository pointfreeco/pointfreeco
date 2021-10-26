import Either
import Mailgun
import Models
import PointFreePrelude
import Prelude

public func deliverGifts() -> EitherIO<Error, Prelude.Unit> {
  Current.database.fetchGiftsToDeliver()
    .flatMap { gifts in
      sequence(
        gifts.map { gift in
          gift.stripePaymentIntentStatus == .succeeded
            ? sendGiftEmail(for: gift)
              |> delay(.milliseconds(200))
              |> retry(maxRetries: 3, backoff: { .seconds(10 * $0) })
              |> flatMap(const(Current.database.updateGiftStatus(gift.id, .succeeded, true)))
            : pure(gift)
        }
      )
    }
    .flatMap {
      sendEmail(
        to: adminEmails,
        subject: "Gift emails sent",
        content: inj1("\($0.count) gift emails sent")
      )
    }
    .map(const(unit))
}
