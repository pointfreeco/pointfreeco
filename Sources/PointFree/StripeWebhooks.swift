import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide
import View

let stripeWebhookMiddleware =
  validateStripeSignature
    <<< filterMap(
      ^\Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.data.object
        >>> either(^\.subscription, ^\.id)
        >>> pure,
      or: writeStatus(.badRequest) >=> end // FIXME: admin email?
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
          var requestDump = ""
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
              subject: "[PointFree Error] Stripe Hook Failed!",
              content: inj1(requestDump)
              ).run
            ).run { _ in }

          return conn |> writeStatus(.badRequest) >=> end
      }

      return conn |> middleware
    }
}

private func isSignatureValid(timestamp: TimeInterval, payload: String) -> (String) -> Bool {
  return { signature in
    let secret = Current.envVars.stripe.endpointSecret
    guard let digest = hexDigest(value: "\(Int(timestamp)).\(payload)", asciiSecret: secret) else { return false }

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
      .flatMap(Current.database.updateStripeSubscription)
      .mapExcept(requireSome)
      .flatMap { subscription in
        Current.database.fetchUserById(subscription.userId)
          .mapExcept(requireSome)
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

private func sendPastDueEmail(to owner: Database.User)
  -> EitherIO<Error, Mailgun.SendEmailResponse> {

    return sendEmail(
      to: [owner.email],
      subject: "Your subscription is past-due",
      content: inj2(pastDueEmailView.view(unit))
    )
}

let pastDueEmailView = simpleEmailLayout(pastDueEmailBodyView)
  .contramap { unit in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Your subscription is past-due",
      preheader: "Your most recent payment was declined.",
      template: .default,
      data: unit
    )
}

private let pastDueEmailBodyView = View<Prelude.Unit> { _ in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["Payment failed"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            """
            Your most recent subscription payment was declined. This could be due to a change in your card
            number, your card expiring, cancellation of your credit card, or the card issuer not recognizing
            the payment and therefore taking action to prevent it.
            """
            ]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            """
            Please update your payment info to ensure uninterrupted access to Point-Free!
            """
            ]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([href(url(to: .account(.paymentInfo(.show(expand: nil))))), `class`([Class.pf.components.button(color: .purple)])],
              ["Update payment info"])
            ])
          ])
        ])
      ])
    ])
}
