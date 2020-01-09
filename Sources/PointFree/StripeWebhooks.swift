import Css
import FunctionalCss
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import Stripe

let stripeWebhookMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Event<Either<Invoice, Stripe.Subscription>>,
  Data
  >
  = validateStripeSignature
    <<< filterMap(
      extraSubscriptionId(fromEvent:)
        >>> pure,
      or: stripeHookFailure(
        subject: "[PointFree Error] Stripe Hook Failed!",
        body: "Couldn't extract subscription id from event payload."
      )
    )
    <| handleFailedPayment

private func validateStripeSignature<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { conn in
      let pairs = conn.request.value(forHTTPHeaderField: "Stripe-Signature")
        .map(keysWithAllValues(separator: ","))
        ?? []

      let params = Dictionary(pairs, uniquingKeysWith: +)

      guard
        let timestamp = params["t"]?.first.flatMap(Int.init).map(TimeInterval.init),
        shouldTolerate(timestamp),
        let signatures = params["v1"],
        let payload = conn.request.httpBody.map({ String(decoding: $0, as: UTF8.self) }),
        signatures.contains(where: isSignatureValid(timestamp: timestamp, payload: payload))
        else {
          return conn
            |> stripeHookFailure(
              subject: "[PointFree Error] Stripe Hook Failed!",
              body: "Couldn't verify signature."
          )
      }

      return conn |> middleware
    }
}

private func isSignatureValid(timestamp: TimeInterval, payload: String) -> (String) -> Bool {
  return { signature in
    let secret = Current.envVars.stripe.endpointSecret
    guard let digest = hexDigest(value: "\(Int(timestamp)).\(payload)", asciiSecret: secret.rawValue) else { return false }

    let constantTimeSignature =
      signature.count == digest.count
        ? signature
        : String(repeating: " ", count: digest.count)

    // NB: constant-time equality check
    return zip(constantTimeSignature.utf8, digest.utf8).reduce(true) { $0 && $1.0 == $1.1 }
  }
}

private func shouldTolerate(_ timestamp: TimeInterval, tolerance: TimeInterval = 5 * 60) -> Bool {
  return Date(timeIntervalSince1970: timestamp)
    > Current.date().addingTimeInterval(-tolerance)
}

private func keysWithAllValues(separator: Character) -> (String) -> [(String, [String])] {
  return { string in
    string.split(separator: separator)
      .compactMap { pair -> (String, [String])? in
        let pair = pair.split(separator: "=", maxSplits: 1).map(String.init)
        return tuple <¢> pair.first <*> (pair.count == 2 ? [pair[1]] : nil)
    }
  }
}

private func handleFailedPayment(
  _ conn: Conn<StatusLineOpen, Stripe.Subscription.Id>
  )
  -> IO<Conn<ResponseEnded, Data>> {

    return Current.stripe.fetchSubscription(conn.data)
      .withExcept(notifyError(subject: "Stripe Hook failed: Couldn't find stripe subscription."))
      .flatMap(Current.database.updateStripeSubscription)
      .mapExcept(requireSome)
      .withExcept(notifyError(subject: "Stripe Hook failed: Couldn't find updated subscription."))
      .flatMap { subscription in
        Current.database.fetchUserById(subscription.userId)
          .mapExcept(requireSome)
          .withExcept(notifyError(subject: "Stripe Hook failed: Couldn't find user."))
          .map { ($0, subscription) }
      }
      .withExcept(notifyError(subject: "Stripe Hook failed for \(conn.data)"))
      .run
      .flatMap(
        either(const(conn |> writeStatus(.badRequest) >=> end)) { user, subscription in
          if subscription.stripeSubscriptionStatus == .pastDue {
            parallel(sendPastDueEmail(to: user).run)
              .run { _ in }
          }

          return conn |> writeStatus(.ok) >=> end
        }
    )
}

private func sendPastDueEmail(to owner: User)
  -> EitherIO<Error, SendEmailResponse> {

    return sendEmail(
      to: [owner.email],
      subject: "Your subscription is past-due",
      content: inj2(pastDueEmailView(unit))
    )
}

let pastDueEmailView = simpleEmailLayout(pastDueEmailBodyView) <<< { unit in
  SimpleEmailLayoutData(
    user: nil,
    newsletter: nil,
    title: "Your subscription is past-due",
    preheader: "Your most recent payment was declined.",
    template: .default,
    data: unit
  )
}

private func pastDueEmailBodyView(_: Prelude.Unit) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])],
            "Payment failed"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            """
            Your most recent subscription payment was declined. This could be due to a change in your card
            number, your card expiring, cancellation of your credit card, or the card issuer not recognizing
            the payment and therefore taking action to prevent it.
            """
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            """
            Please update your payment info to ensure uninterrupted access to Point-Free!
            """
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attributes: [
                .href(url(to: .account(.paymentInfo(.show)))),
                .class([Class.pf.components.button(color: .purple)])
              ],
              "Update payment info"
            )
          )
        )
      )
    )
  )
}

private func stripeHookFailure<A>(
  subject: String = "[PointFree Error] Stripe Hook Failed!",
  body: String
  )
  -> (Conn<StatusLineOpen, A>)
  -> IO<Conn<ResponseEnded, Data>> {

    return { conn in
      return IO<Void> {
        var requestDump = body + "\n\n"
        print("Current timestamp: \(Current.date().timeIntervalSince1970)", to: &requestDump)
        print(
          "\n\(conn.request.httpMethod ?? "?METHOD?") \(conn.request.url?.absoluteString ?? "?URL?")",
          to: &requestDump
        )
        print("\nHeaders:", to: &requestDump)
        dump(conn.request.allHTTPHeaderFields, to: &requestDump)
        print("\nBody:", to: &requestDump)
        print(String(decoding: conn.request.httpBody ?? .init(), as: UTF8.self), to: &requestDump)

        parallel(
          sendEmail(
            to: adminEmails,
            subject: subject,
            content: inj1(requestDump)
            ).run
          ).run { _ in }
        }
        .flatMap {
          conn
            |> writeStatus(.badRequest)
            >=> respond(text: body)
      }
    }
}

private func extraSubscriptionId(
  fromEvent event: Event<Either<Invoice, Stripe.Subscription>>
  ) -> Stripe.Subscription.Id? {

  switch event.data.object {
  case let .left(invoice):
    return invoice.subscription
      ?? invoice.lines.data.compactMap(^\.subscription).first
  case let .right(subscription):
    return subscription.id
  }
}
