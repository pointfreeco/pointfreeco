import Backtrace
import Either
import Foundation
import PointFree

// Bootstrap

Backtrace.install()

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

_ = sendWelcomeEmails()
  .run
  .perform()

_ = validateEnterpriseEmails()
  .run
  .perform()
