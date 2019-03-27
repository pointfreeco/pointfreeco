import Either
import Foundation
import PointFree

// Bootstrap

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

// TODO
//_ = sendWelcomeEmails()
//  .run
//  .perform()

_ = validateEnterpriseEmails()
  .run
  .perform()
