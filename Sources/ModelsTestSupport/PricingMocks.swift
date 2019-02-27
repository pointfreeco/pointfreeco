import Models
import Optics
import Prelude

extension Pricing {
  public static let mock = `default`

  public static let individualMonthly = mock
    |> \.billing .~ .monthly
    |> \.quantity .~ 1

  public static let individualYearly = mock
    |> \.billing .~ .yearly
    |> \.quantity .~ 1

  public static let teamMonthly = mock
    |> \.billing .~ .monthly
    |> \.quantity .~ 4

  public static let teamYearly = mock
    |> \.billing .~ .yearly
    |> \.quantity .~ 4
}
