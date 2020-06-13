import Either
import Foundation
import PointFree
import Prelude

// Bootstrap

_ = try!
  PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

_ = EitherIO.debug(prefix: "📧 Sending welcome emails...")
  .flatMap(const(sendWelcomeEmails()))
  .run
  .perform()

//_ = validateEnterpriseEmails()
//  .run
//  .perform()
