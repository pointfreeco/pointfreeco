import Foundation
@testable import PointFree

let urlString = "http://localhost:8080/account/subscription/change"

dump(router.match(string: urlString))
