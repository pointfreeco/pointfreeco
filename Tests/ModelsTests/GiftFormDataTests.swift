import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import Models

@MainActor
final class GiftFormDataTests: TestCase {
  func testCodable_PaymentIntent() async throws {
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
    await _assertInlineSnapshot(
      matching: String(decoding: data, as: UTF8.self), as: .lines,
      with: """
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

  func testCodable_PaymentMethod() async throws {
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
    await _assertInlineSnapshot(
      matching: String(decoding: data, as: UTF8.self), as: .lines,
      with: """
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
