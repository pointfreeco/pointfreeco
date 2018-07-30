import Either
import Foundation
import PointFree

// Bootstrap

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

_ = sendWelcomeEmails()
  .run
  .perform()
