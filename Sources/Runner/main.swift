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

//_ = EitherIO.debug(prefix: "📧 Sending welcome emails...")
//  .flatMap(const(sendWelcomeEmails()))
//  .run
//  .perform()

//_ = validateEnterpriseEmails()
//  .run
//  .perform()

@testable import HttpPipeline
import Models

/*
 UPDATE "users"
 SET "rss_salt" = "legacy_rss_salt"
 WHERE "legacy_rss_salt" IS NOT NULL
 */

let result = Current.database.execute(
  """
  ALTER TABLE "users"
  ADD COLUMN IF NOT EXISTS
  "legacy_rss_salt" character varying
  """
)
  .flatMap { _ in
    Current.database.execute(
      """
      SELECT "id", "rss_salt" FROM "users" WHERE "legacy_rss_salt" IS NULL
      """
    )
      .flatMap { rows -> EitherIO<Error, Prelude.Unit> in
        sequence(
          rows.map { row -> EitherIO<Error, Prelude.Unit> in
            let userId = try! row.decode(column: "id", as: Models.User.Id.self)
            let rssSalt = try! row.decode(column: "rss_salt", as: Models.User.RssSalt.self)
            let secret = Current.envVars.appSecret.rawValue
            let encryptedUserId = encrypted(text: userId.rawValue.uuidString, secret: secret)!
            let encryptedRssSalt = encrypted(text: rssSalt.rawValue.uuidString, secret: secret)!
            let legacyRssSalt = "\(encryptedUserId)/\(encryptedRssSalt)"

            return Current.database.execute(
              """
              UPDATE "users"
              SET "legacy_rss_salt" = \(bind: legacyRssSalt)
              WHERE "id" = \(bind: userId)
              """
            )
              .map(const(unit))
          }
        )
          .map(const(unit))
      }
  }
  .run
  .perform()

dump(result)

