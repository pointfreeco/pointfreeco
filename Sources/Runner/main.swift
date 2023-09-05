import Either
import Foundation
import NIO
import PointFree
import Prelude

// Bootstrap

await PointFree.bootstrap()

print("📧 Sending welcome emails...")
try await sendWelcomeEmails()

_ = try await EitherIO.debug(prefix: "📧 Delivering gifts...")
  .flatMap(const(deliverGifts()))
  .performAsync()

//_ = await validateEnterpriseEmails()
//  .performAsync()
