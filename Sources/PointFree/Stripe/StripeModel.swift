import Either
import Foundation
import Optics
import Prelude

private let subscriptionPlanIds = [
  "yearly", "monthly", "yearly-team", "monthly-team"
]

public let subscriptionPlans = fetchPlans
  .map(map(get(\.data)))
