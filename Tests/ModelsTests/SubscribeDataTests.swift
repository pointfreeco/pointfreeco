import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import Models

//final class SubscribeDataTests: TestCase {
//  func testPaymentMethod() throws {
//    let originalData = SubscribeData(
//      coupon: nil,
//      isOwnerTakingSeat: true,
//      paymentType: .paymentMethodID("pm_deadbeef"),
//      pricing: .individualMonthly,
//      referralCode: nil,
//      teammates: [],
//      useRegionalDiscount: false
//    )
//    let data = try encoder.encode(originalData)
//
//    _assertInlineSnapshot(matching: String(decoding: data, as: UTF8.self), as: .customDump, with: #"""
//    "{\"isOwnerTakingSeat\":true,\"paymentMethodID\":\"pm_deadbeef\",\"pricing\":{\"billing\":\"monthly\",\"lane\":\"personal\",\"quantity\":1},\"teammates\":[],\"useRegionalDiscount\":false}"
//    """#)
//
//    let decodedSubscriberData = try JSONDecoder().decode(SubscribeData.self, from: data)
//    XCTAssertEqual(decodedSubscriberData, originalData)
//  }
//
//  func testToken() throws {
//    let originalData = SubscribeData(
//      coupon: nil,
//      isOwnerTakingSeat: true,
//      paymentType: .token("token_deadbeef"),
//      pricing: .individualMonthly,
//      referralCode: nil,
//      teammates: [],
//      useRegionalDiscount: false
//    )
//    let data = try encoder.encode(originalData)
//
//    _assertInlineSnapshot(matching: String(decoding: data, as: UTF8.self), as: .customDump, with: #"""
//    "{\"isOwnerTakingSeat\":true,\"pricing\":{\"billing\":\"monthly\",\"lane\":\"personal\",\"quantity\":1},\"teammates\":[],\"token\":\"token_deadbeef\",\"useRegionalDiscount\":false}"
//    """#)
//
//    let decodedSubscriberData = try JSONDecoder().decode(SubscribeData.self, from: data)
//    XCTAssertEqual(decodedSubscriberData, originalData)
//  }
//}

private let encoder = {
  let _encoder = JSONEncoder()
  _encoder.outputFormatting = [.sortedKeys]
  return _encoder
}()
