#if os(Linux)
import Glibc
#else
import Darwin
#endif

@_implementationOnly import SwiftICU
import Logging

public struct Locale: Hashable {

    // MARK: - Properties

    public static var logger = Logger(label: "locale.logger")
    public let identifier: String
    
    public var language: String
    public var region: String? = nil
    public var script: String? = nil

    // MARK: - Initialization

    public init(_ identifier: String) throws {
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
            throw InitializationError.valueCallFailure(whileUsing: functionDescription, errorCode: Int(error.pointee.rawValue), status: Int(resultCode))
        }
    }

}
