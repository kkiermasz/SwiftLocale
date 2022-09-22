extension Locale {

    enum InitializationError: Error {
        case valueCallFailure(whileUsing: String, errorCode: Int, status: Int)
        case emptyResult
    }

}

extension Locale {

    enum AcceptedLanguageNegotiationError: Error {
        case internalICUError(code: Int)
        case invalidICUResult
        case invalidInput
    }

}
