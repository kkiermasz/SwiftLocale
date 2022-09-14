@testable import SwiftLocale

import Nimble
import XCTest

final class Locale_Tests: XCTestCase {

    func test_Initialization() throws {
        let identifier = "en_US"
        let result = try SwiftLocale.Locale(identifier: identifier)

        expect(result.language).to(equal("en"))
        expect(result.region).to(equal("US"))
        expect(result.script).to(beNil())
    }

}
