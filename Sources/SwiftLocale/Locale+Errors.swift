import SwiftICU

extension Locale {

    enum InitializationError: Error {
        case valueCallFailure(whileUsing: String, errorCode: UErrorCode, status: Int)
        case emptyResult
    }

}

extension Locale {

    enum AcceptedLanguageNegotiationError: Error {
        case internalICUError(code: UErrorCode)
        case invalidICUResult
        case invalidInput
    }

}
