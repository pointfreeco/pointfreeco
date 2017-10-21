import Either
import Foundation
import Prelude
import Optics

func fetch(planId id: String) -> EitherIO<Prelude.Unit, StripeSubscriptionPlan> {
  let request = URLRequest(url: URL.init(string: "https://api.stripe.com/v1/plans/\(id)")!)
    |> \.allHTTPHeaderFields %~ attachStripeAuthorization

  // todo: can EitherIO be a typealias with overloads?
  return EitherIO<Prelude.Unit, StripeSubscriptionPlan>(run: .init { callback in

    let session = URLSession(configuration: .default)
    session.dataTask(with: request) { data, response, error in
      defer { session.invalidateAndCancel() }
      guard
        let data = data,
        let masterPlan = try? JSONDecoder().decode(StripeSubscriptionPlan.self, from: data)
        else {
          callback(.left(unit))
          return
      }

      callback(.right(masterPlan))
      }
      .resume()
    })
}

private func attachStripeAuthorization(_ headers: [String: String]?) -> [String: String] {
  return (headers ?? [:])
    |> key("Authorization") .~ ("Basic " + Data("\(EnvVars.Stripe.secretKey):".utf8).base64EncodedString())
}
