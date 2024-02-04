#if os(Linux)
import Glibc
#else
import Darwin
#endif

import FoundationICU
import Logging

extension Locale {

    /// Provides functions to negotiate the best locale to use.
    /// For example, a browser sends the web server the HTTP `Accept-Language` header indicating which locales, with a ranking, are acceptable to the user.
    /// The server must determine which locale to use when returning content to the user.
    /// - Parameters:
    ///   - acceptLanguageHeader: HTTP's `Accept-Language:` header
    ///   - available: The list of `Locale`s that will be accepted in the negotiation process. If not specifier - all `Locale`s will be accepted
    ///   - allowFallback: Tells whether to seek for a fallback in negotiation process.
    ///                    For example, the `Accept-Language` list includes `ja_JP` and is matched with available locale `ja`,
    ///                    when no `ja_JP` included in `available` list
    /// - Returns: Locale negotiation result
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


        defer {
            error.deallocate()
            result?.deallocate()
            acceptResult.deallocate()
            httpAcceptLanguage?.deallocate()
            cargs.forEach { $0?.deallocate() }
        }

        guard error.pointee.rawValue <= 0, let httpAcceptLanguage else {
            let reason = String(describing: AcceptedLanguageNegotiationError.invalidInput)
            logger.info("Locale negotiation ended with failure: \(reason)")
            return nil
        }

        error.pointee = U_ZERO_ERROR

        uloc_acceptLanguageFromHTTP(result, 1000, acceptResult, httpAcceptLanguage, avaialableLocales, error)

        guard error.pointee.rawValue <= 0 else {
            let reason = String(describing: AcceptedLanguageNegotiationError.internalICUError(code: Int(error.pointee.rawValue)))
            logger.info("Locale negotiation ended with failure: \(reason)")
            return nil
        }
        guard let result, let locale = try? Locale(String(cString: result)) else {
            let reason = String(describing: AcceptedLanguageNegotiationError.invalidICUResult)
            logger.info("Locale negotiation ended with failure: \(reason)")
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
