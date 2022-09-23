@testable import SwiftLocale
import XCTest

final class Locale_AcceptLanguage_Tests: XCTestCase {

    private struct TestData {
        let httpAcceptLanguageHeader: String
        let available: [SwiftLocale.Locale]?
        let allowFallback: Bool
        let expectedResult: SwiftLocale.Locale?

        init(_ httpAcceptLanguageHeader: String, _ available: [SwiftLocale.Locale]?, _ allowFallback: Bool, _ expectedResult: SwiftLocale.Locale?) {
            self.httpAcceptLanguageHeader = httpAcceptLanguageHeader
            self.available = available
            self.allowFallback = allowFallback
            self.expectedResult = expectedResult
        }
    }

    func test_AcceptLanguage() {
        for data in testsDataWithFallback + testsDataWithoutFallback {
            let result = SwiftLocale.Locale.acceptLanguage(data.httpAcceptLanguageHeader, available: data.available, allowFallback: data.allowFallback)

            XCTAssertEqual(result, data.expectedResult)
        }
    }

    // Tests data copied from icu4c https://github.com/unicode-org/icu/blob/main/icu4c/source/test/cintltst/cloctst.c

    private let testsDataWithFallback = [
        TestData("""
                 mt-mt, ja;q=0.76, en-us;q=0.95, en;q=0.92, en-gb;q=0.89, fr;q=0.87,\
                 iu-ca;q=0.84, iu;q=0.82, ja-jp;q=0.79, mt;q=0.97, de-de;q=0.74, de;q=0.71,\
                 es;q=0.68, it-it;q=0.66, it;q=0.63, vi-vn;q=0.61, vi;q=0.58,\
                 nl-nl;q=0.55, nl;q=0.53, th-th-traditional;q=0.01
                 """, nil, true, try! .init("mt_MT")),
        TestData("ja;q=0.5, en;q=0.8, tlh", nil, true, try! .init("en")),
        TestData("en-wf, de-lx;q=0.8", nil, true, try! .init("en_GB")),
        TestData("mga-ie;q=0.9, sux", nil, true, nil),
        TestData("""
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xx-yy;q=0.1,\
                 es
                 """, nil, true, try! .init("es")),
        TestData("zh-xx;q=0.9, en;q=0.6", nil, true, try! .init("zh")),
        TestData("ja-JA", nil, true, try! .init("ja")),
        TestData("zh-xx;q=0.9", nil, true, try! .init("zh")),
        TestData("""
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                 """, nil, true, nil),
        TestData("""
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB
                 """, nil, true, nil),
        TestData("""
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABC
                 """, nil, true, nil),
        TestData("""
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                 """, nil, true, nil),
    ]

    private let testsDataWithoutFallback = [
        TestData("""
                 mt-mt, ja;q=0.76, en-us;q=0.95, en;q=0.92, en-gb;q=0.89, fr;q=0.87,\
                 iu-ca;q=0.84, iu;q=0.82, ja-jp;q=0.79, mt;q=0.97, de-de;q=0.74, de;q=0.71,\
                 es;q=0.68, it-it;q=0.66, it;q=0.63, vi-vn;q=0.61, vi;q=0.58,\
                 nl-nl;q=0.55, nl;q=0.53, th-th-traditional;q=0.01
                 """, nil, false, try! .init("mt_MT")),
        TestData("ja;q=0.5, en;q=0.8, tlh", nil, false, try! .init("en")),
        TestData("en-wf, de-lx;q=0.8", nil, false, nil),
        TestData("mga-ie;q=0.9, sux", nil, false, nil),
        TestData("""
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01,\
                 xxx-yyy;q=0.01, xxx-yyy;q=0.01, xxx-yyy;q=0.01, xx-yy;q=0.1,\
                 es
                 """, nil, false, try! .init("es")),
        TestData("zh-xx;q=0.9, en;q=0.6", nil, false, nil),
        TestData("ja-JA", nil, false, nil),
        TestData("zh-xx;q=0.9", nil, false, nil),
        TestData("""
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                 """, nil, false, nil),
        TestData("""
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB
                 """, nil, false, nil),
        TestData("""
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABC
                 """, nil, false, nil),
        TestData("""
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
                 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                 """, nil, false, nil),
    ]

}
