import Either
import Foundation
import PointFree

// Bootstrap

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

_ = sendEmail(
  to: adminEmails,
  subject: "Testing cron!",
  content: inj1("This cron fired correctly! The date is \(Date())).")
  )
  .run
  .perform()
