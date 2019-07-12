import XCTest

import S3StorageTests

var tests = [XCTestCaseEntry]()
tests += S3StorageTests.__allTests()

XCTMain(tests)
