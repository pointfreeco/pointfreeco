import Either
import Foundation
import NIO
import PointFree
import Prelude

// Bootstrap

await PointFree.bootstrap()

_ = try await EitherIO.debug(prefix: "📧 Sending welcome emails...")
  .flatMap(const(sendWelcomeEmails()))
  .performAsync()

_ = try await EitherIO.debug(prefix: "📧 Delivering gifts...")
  .flatMap(const(deliverGifts()))
  .performAsync()

//_ = await validateEnterpriseEmails()
//  .performAsync()
