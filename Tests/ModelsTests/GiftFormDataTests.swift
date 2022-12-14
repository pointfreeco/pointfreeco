import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import Models

final class GiftFormDataTests: TestCase {
  func testCodable_PaymentIntent() throws {
    let giftFormData = GiftFormData(
      deliverAt: nil,
      fromEmail: "blob@pointfree.co",
      fromName: "Blob",
      message: "Happy Birthday!",
      monthsFree: 12,
      paymentMethodID: "pm_deadbeef",
      toEmail: "blob.jr",
      toName: "Blob Jr."
    )

    let data = try encoder.encode(giftFormData)
    _assertInlineSnapshot(matching: String(decoding: data, as: UTF8.self), as: .lines, with: """
    {
      "fromEmail" : "blob@pointfree.co",
      "fromName" : "Blob",
      "message" : "Happy Birthday!",
      "monthsFree" : "12",
      "paymentMethodID" : "pm_deadbeef",
      "toEmail" : "blob.jr",
      "toName" : "Blob Jr."
    }
    """)

    let roundtripGiftFormData = try JSONDecoder().decode(GiftFormData.self, from: data)
    XCTAssertEqual(roundtripGiftFormData, giftFormData)
  }

  func testCodable_PaymentMethod() throws {
    let giftFormData = GiftFormData(
      deliverAt: nil,
      fromEmail: "blob@pointfree.co",
      fromName: "Blob",
      message: "Happy Birthday!",
      monthsFree: 12,
      paymentMethodID: "pm_deadbeef",
      toEmail: "blob.jr",
      toName: "Blob Jr."
    )

    let data = try encoder.encode(giftFormData)
    _assertInlineSnapshot(matching: String(decoding: data, as: UTF8.self), as: .lines, with: """
    {
      "fromEmail" : "blob@pointfree.co",
      "fromName" : "Blob",
      "message" : "Happy Birthday!",
      "monthsFree" : "12",
      "paymentMethodID" : "pm_deadbeef",
      "toEmail" : "blob.jr",
      "toName" : "Blob Jr."
    }
    """)

    let roundtripGiftFormData = try JSONDecoder().decode(GiftFormData.self, from: data)
    XCTAssertEqual(roundtripGiftFormData, giftFormData)
  }
}

private let encoder = {
  let _encoder = JSONEncoder()
  _encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
  return _encoder
}()
