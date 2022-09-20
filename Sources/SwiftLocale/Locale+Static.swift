#if os(Linux)
import Glibc
#else
import Darwin
#endif

import SwiftICU

extension Locale {

    public static func acceptLanguage(_ acceptLanguageHeader: String, available: [Locale]? = nil, allowFallback: Bool = true) -> Locale? {
        let result = strdup("")
        let acceptResult = UnsafeMutablePointer<UAcceptResult>.allocate(capacity: 1)
        let httpAcceptLanguage = strdup(acceptLanguageHeader)

        let available = available ?? self.available
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
        guard let result, let locale = try? Locale(String(cString: result)) else {
            assertionFailure(String(describing: AcceptedLanguageNegotiationError.invalidICUResult))
            return nil
        }
        switch acceptResult.pointee {
        case ULOC_ACCEPT_FALLBACK: return allowFallback ? locale : nil
        case ULOC_ACCEPT_VALID: return locale
        default: return nil
        }
    }

    public static var available: [Locale] {
        let count = uloc_countAvailable()
        var result = [Locale]()
        for n in 0 ..< count {
            let localeIdentifier = uloc_getAvailable(n)
            guard let localeIdentifier,
                  let locale = try? Locale(String(cString: localeIdentifier))
            else { break }
            result.append(locale)
        }
        return result
    }

}
