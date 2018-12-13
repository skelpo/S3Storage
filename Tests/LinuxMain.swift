import XCTest

import S3StorageTests

var tests = [XCTestCaseEntry]()
tests += S3StorageTests.allTests()
XCTMain(tests)