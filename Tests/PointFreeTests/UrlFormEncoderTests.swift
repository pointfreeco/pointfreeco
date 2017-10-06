import HttpPipeline
import HttpPipelineTestSupport
import Optics
@testable import PointFree
import Prelude
import SnapshotTesting
import XCTest

class UrlFormEncoderTests: TestCase {
  func testEncoding_DeepObject() {
    assertSnapshot(
      matching: urlFormEncode(
        value: [
          "id": 42,
          "name": "Blob McBlob",
          "bio": "!*'();:@&=+$,/?%#[] ^",
          "favorite_colors": ["blue", "green"],
          "location": [
            "id": 12,
            "name": "Brooklyn",
            "neighborhoods": [
              ["id": 2, "name": "Williamsburg"],
              ["id": 3, "name": "Bed-Stuy"],
            ]
          ]
        ]
        ).replacingOccurrences(of: "&", with: "&\n")
    )
  }

  func testEncoding_Emtpy() {
    assertSnapshot(
      matching: urlFormEncode(
        value: [
          "id": 42,
          "name": "Blob McBlob",
          "empty_array": [],
          "empty_object": [:],
        ]
        ).replacingOccurrences(of: "&", with: "&\n")
    )
  }

  func testEncoding_RootArray_SimpleObjects() {
    assertSnapshot(
      matching: urlFormEncode(
        values: ["Functions & Purity", "Monoids", "Applicatives"],
        rootKey: "episodes"
        )
        .replacingOccurrences(of: "&", with: "&\n")
    )
  }

  func testEncoding_DoubleArray() {
    assertSnapshot(
      matching: urlFormEncode(
        values: [
          ["Functions", "Purity"],
          ["Semigroups", "Monoids"],
          ["Applicatives", "Monads"]
        ],
        rootKey: "episodes"
        )
        .replacingOccurrences(of: "&", with: "&\n")
    )
  }
}
