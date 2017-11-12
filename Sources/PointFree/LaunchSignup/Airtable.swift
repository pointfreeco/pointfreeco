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

      return .init(
        run: .init { callback in
          // TODO: make an `IO` helper for `URLSession` that does clean up automatically
          let session = URLSession(configuration: .default)
          session
            .dataTask(with: request) { data, response, error in
              callback(error == nil ? .right(unit) : .left(unit))
              session.finishTasksAndInvalidate()
            }
            .resume()
        }
      )
    }
}
