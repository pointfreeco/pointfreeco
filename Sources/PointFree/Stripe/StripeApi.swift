import Either
import Foundation
import Prelude
import Optics

extension EitherIO {
  public func `catch`(_ f: @escaping (E) -> EitherIO) -> EitherIO {
    return catchE(self, f)
  }

  public func mapExcept<F, B>(_ f: @escaping (Either<E, A>) -> Either<F, B>) -> EitherIO<F, B> {
    return .init(
      run: self.run.map(f)
    )
  }

  public func withExcept<F>(_ f: @escaping (E) -> F) -> EitherIO<F, A> {
    return self.bimap(f, id)
  }
}

func fetchPlans() -> EitherIO<Prelude.Unit, [StripeSubscriptionPlan]> {
  let request = auth <| URLRequest(url: URL(string: "https://api.stripe.com/v1/plans")!)

  return jsonDataTask(with: request).withExcept(const(unit))
}

func fetch(planId id: String) -> EitherIO<Prelude.Unit, StripeSubscriptionPlan> {
  let request = auth <|  URLRequest(url: URL(string: "https://api.stripe.com/v1/plans/\(id)")!)

  return jsonDataTask(with: request).withExcept(const(unit))
}

private func auth(_ request: URLRequest) -> URLRequest {
  return request |> \.allHTTPHeaderFields %~ attachStripeAuthorization
}

private func attachStripeAuthorization(_ headers: [String: String]?) -> [String: String] {
  let secret = Data("\(AppEnvironment.current.envVars.stripe.secretKey):".utf8).base64EncodedString()
  return (headers ?? [:])
    |> \.["Authorization"] .~ ("Basic " + secret)
}
