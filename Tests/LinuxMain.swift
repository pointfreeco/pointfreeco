import XCTest

import FunctionalCssTests
import GitHubTests
import ModelsTests
import PointFreeRouterTests
import PointFreeTests
import StripeTests
import StyleguideTests

var tests = [XCTestCaseEntry]()
tests += FunctionalCssTests.__allTests()
tests += GitHubTests.__allTests()
tests += ModelsTests.__allTests()
tests += PointFreeRouterTests.__allTests()
tests += PointFreeTests.__allTests()
tests += StripeTests.__allTests()
tests += StyleguideTests.__allTests()

XCTMain(tests)
