import ApplicativeRouter
import CustomDump
import Database
import Either
import HttpPipeline
@testable import Models
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

class GiftTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.isRecording=true
  }

  func testGiftCreate() {
    var createGiftRequest: Database.Client.CreateGiftRequest!
    Current.database.createGift = { request in
      createGiftRequest = request
      return pure(.mock)
    }

    let conn = connection(
      from: request(
        to: .gifts(
          .create(
            .init(
              deliverAt: nil,
              fromEmail: "blob@pointfree.co",
              fromName: "Blob",
              message: "HBD!",
              monthsFree: 3,
              toEmail: "blob.jr@pointfree.co",
              toName: "Blob Jr."
            )
          )
        ),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    POST http://localhost:8080/gifts
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={}
    
    {
      "from_email" : "blob@pointfree.co",
      "from_name" : "Blob",
      "message" : "HBD!",
      "months_free" : 3,
      "to_email" : "blob.jr@pointfree.co",
      "to_name" : "Blob Jr."
    }
    
    200 OK
    Content-Length: 44
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    
    {
      "clientSecret" : "pi_test_secret_test"
    }
    """)

    XCTAssertNoDifference(
      createGiftRequest,
        .init(
          deliverAt: nil,
          fromEmail: "blob@pointfree.co",
          fromName: "Blob",
          message: "HBD!",
          monthsFree: 3,
          stripeCouponId: nil,
          stripePaymentIntentId: "pi_test",
          toEmail: "blob.jr@pointfree.co",
          toName: "Blob Jr."
        )
    )
  }

  func testGiftCreate_StripeFailure() {
    Current.stripe.createPaymentIntent = { _ in
      struct Error: Swift.Error {}
      return throwE(Error())
    }

    let conn = connection(
      from: request(
        to: .gifts(
          .create(
            .init(
              deliverAt: nil,
              fromEmail: "blob@pointfree.co",
              fromName: "Blob",
              message: "HBD!",
              monthsFree: 3,
              toEmail: "blob.jr@pointfree.co",
              toName: "Blob Jr."
            )
          )
        ),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    POST http://localhost:8080/gifts
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={}
    
    {
      "from_email" : "blob@pointfree.co",
      "from_name" : "Blob",
      "message" : "HBD!",
      "months_free" : 3,
      "to_email" : "blob.jr@pointfree.co",
      "to_name" : "Blob Jr."
    }
    
    400 Bad Request
    Content-Length: 65
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    
    {
      "errorMessage" : "Unknown error with our payment processor"
    }
    """)
  }

  func testGiftCreate_InvalidMonths() {
    Current.stripe.createPaymentIntent = { _ in
      struct Error: Swift.Error {}
      return throwE(Error())
    }

    let conn = connection(
      from: request(
        to: .gifts(
          .create(
            .init(
              deliverAt: nil,
              fromEmail: "blob@pointfree.co",
              fromName: "Blob",
              message: "HBD!",
              monthsFree: 1,
              toEmail: "blob.jr@pointfree.co",
              toName: "Blob Jr."
            )
          )
        ),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    POST http://localhost:8080/gifts
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={}
    
    {
      "from_email" : "blob@pointfree.co",
      "from_name" : "Blob",
      "message" : "HBD!",
      "months_free" : 1,
      "to_email" : "blob.jr@pointfree.co",
      "to_name" : "Blob Jr."
    }
    
    400 Bad Request
    Content-Length: 45
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    
    {
      "errorMessage" : "Unknown gift option."
    }
    """)
  }
}
