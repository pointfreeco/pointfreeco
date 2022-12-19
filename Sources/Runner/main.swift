import Either
import Foundation
import NIO
import PointFree
import Prelude

// Bootstrap

#if DEBUG
  let numberOfThreads = 1
#else
  let numberOfThreads = System.coreCount
#endif
let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)

_ =
  try await PointFree
  .bootstrap(eventLoopGroup: eventLoopGroup)
  .performAsync()

_ = try await EitherIO.debug(prefix: "📧 Sending welcome emails...")
  .flatMap(const(sendWelcomeEmails()))
  .performAsync()

_ = try await EitherIO.debug(prefix: "📧 Delivering gifts...")
  .flatMap(const(deliverGifts()))
  .performAsync()

//_ = await validateEnterpriseEmails()
//  .performAsync()
