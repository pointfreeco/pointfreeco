import XCTest
@testable import PreludeTests
@testable import ApplicativeRouterTests
@testable import HTMLTests
@testable import HTTPipelineTests

XCTMain([
  testCase(StyleguideTests.allTests),
  testCase(GridTests.allTests),
])
