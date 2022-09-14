import SwiftICU

extension Locale {

    enum InitializationError: Error {
        case valueCallFailure(whileUsing: String, errorCode: UErrorCode, status: Int)
        case emptyResult
    }

}
