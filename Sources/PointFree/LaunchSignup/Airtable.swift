import Either
import Foundation
import Optics
import Prelude

func createRow(email: String)
  -> (_ baseId: String)
  -> EitherIO<Prelude.Unit, Prelude.Unit> {
    return { baseId in

      let request = URLRequest(url: URL(string: "https://api.airtable.com/v0/\(baseId)/Emails")!)
        |> \.httpMethod .~ "POST"
        |> \.httpBody .~ (try? JSONEncoder().encode(["fields": ["Email": email]]))
        |> \.allHTTPHeaderFields .~ [
          "Authorization": "Bearer \(AppEnvironment.current.envVars.airtable.bearer)",
          "Content-Type": "application/json"
      ]

      return dataTask(with: request)
        .map(tap(AppEnvironment.current.logger.debug))
        .withExcept(tap(AppEnvironment.current.logger.error) >>> const(unit))
        .map(const(unit))
    }
}
