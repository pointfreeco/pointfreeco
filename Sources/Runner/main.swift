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

_ = try! PointFree
  .bootstrap(eventLoopGroup: eventLoopGroup)
  .run
  .perform()
  .unwrap()

_ = EitherIO.debug(prefix: "📧 Sending welcome emails...")
  .flatMap(const(sendWelcomeEmails()))
  .run
  .perform()

_ = EitherIO.debug(prefix: "📧 Delivering gifts...")
  .flatMap(const(deliverGifts()))
  .run
  .perform()

//_ = validateEnterpriseEmails()
//  .run
//  .perform()
