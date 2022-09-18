#if os(Linux)
import Glibc
#else
import Darwin
#endif

import SwiftICU

public struct Locale {

    // MARK: - Properties

    public let identifier: String
    
    public private(set) var language: String
    public private(set) var region: String? = nil
    public private(set) var script: String? = nil

    // MARK: - Initialization

    public init(identifier: String) throws {
        self.identifier = identifier

        language = try Locale.value(identifier: identifier, from: uloc_getLanguage(_:_:_:_:))
        region = try? Locale.value(identifier: identifier, from: uloc_getCountry(_:_:_:_:))
        script = try? Locale.value(identifier: identifier, from: uloc_getScript(_:_:_:_:))
    }

    // MARK: - Static

    static func value(
        identifier: String,
        from function: (
            _ localeID: UnsafePointer<CChar>,
            _ result: UnsafeMutablePointer<CChar>,
            _ capacity: Int32,
            _ err: UnsafeMutablePointer<UErrorCode>
        ) -> Int32
    ) throws -> String {
        let cLocale = strdup(identifier)
        let result = strdup("")
        let error = UnsafeMutablePointer<UErrorCode>.allocate(capacity: 1)
        error.pointee = U_ZERO_ERROR

        defer {
            error.deallocate()
            result?.deallocate()
            cLocale?.deallocate()
        }
        let resultCode = function(cLocale!, result!, 1000, error)
        
        if error.pointee == U_ZERO_ERROR, let result = result, String(cString: result) != "" {
            return String(cString: result)
        } else if let result = result, String(cString: result) == "" {
            throw InitializationError.emptyResult
        } else {
            let functionDescription = String(describing: type(of: function))
            throw InitializationError.valueCallFailure(whileUsing: functionDescription, errorCode: error.pointee, status: Int(resultCode))
        }
    }

}

extension Locale {

    public static func acceptLanguage(_ acceptLanguageHeader: String, throwback: Locale) -> Locale {
        guard let language = acceptLanguage(acceptLanguageHeader) else {
            return throwback
        }
        return language
    }

    public static func acceptLanguage(_ acceptLanguageHeader: String) -> Locale? {
        let result = strdup("")
        let acceptResult = UnsafeMutablePointer<UAcceptResult>.allocate(capacity: 1)
        let httpAcceptLanguage = strdup(acceptLanguageHeader)

        let available = self.available
        var cargs = available
            .map(\.identifier)
            .map { UnsafePointer<CChar>(strdup($0)) }

        let error = UnsafeMutablePointer<UErrorCode>.allocate(capacity: 1)
        error.pointee = U_ZERO_ERROR
        let avaialableLocales = uenum_openCharStringsEnumeration(&cargs, Int32(available.count), error)

        guard error.pointee.rawValue <= 0, let httpAcceptLanguage else {
            assertionFailure(String(describing: AcceptedLanguageNegotiationError.invalidInput))
            return nil
        }

        error.pointee = U_ZERO_ERROR

        uloc_acceptLanguageFromHTTP(result, 1000, acceptResult, httpAcceptLanguage, avaialableLocales, error)

        guard error.pointee.rawValue <= 0 else {
            assertionFailure(String(describing: AcceptedLanguageNegotiationError.internalICUError(code: error.pointee)))
            return nil
        }
        guard let result, let locale = try? Locale(identifier: String(cString: result)) else {
            assertionFailure(String(describing: AcceptedLanguageNegotiationError.invalidICUResult))
            return nil
        }
        return locale
    }

    public static var available: [Locale] {
        let count = uloc_countAvailable()
        var result = [Locale]()
        for n in 0 ..< count {
            let localeIdentifier = uloc_getAvailable(n)
            guard let localeIdentifier, let locale = try? Locale(identifier: String(cString: localeIdentifier)) else { break }
            result.append(locale)
        }
        return result
    }

}
