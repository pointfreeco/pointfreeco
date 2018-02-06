import Either
import Foundation
import Optics
import Prelude

func createRow(email: EmailAddress)
  -> (_ baseId: String)
  -> EitherIO<Error, Prelude.Unit> {
    return { baseId in

      let request = URLRequest(url: URL(string: "https://api.airtable.com/v0/\(baseId)/Emails")!)
        |> \.httpMethod .~ "POST"
        |> \.httpBody .~ (try? JSONEncoder().encode(["fields": ["Email": email]]))
        |> \.allHTTPHeaderFields .~ [
          "Authorization": "Bearer \(AppEnvironment.current.envVars.airtable.bearer)",
          "Content-Type": "application/json"
      ]

      return dataTask(with: request)
        .map(const(unit))
    }
}
