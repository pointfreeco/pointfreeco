import Models
import Optics
import PointFreePrelude
import Prelude

extension Pricing {
  public static let mock = `default`

  public static let individualMonthly = update(mock) {
    $0.billing = .monthly
    $0.quantity = 1
  }

  public static let individualYearly = update(mock) {
    $0.billing = .yearly
    $0.quantity = 1
  }

  public static let teamMonthly = update(mock) {
    $0.billing = .monthly
    $0.quantity = 4
  }

  public static let teamYearly = update(mock) {
    $0.billing = .yearly
    $0.quantity = 4
  }
}
