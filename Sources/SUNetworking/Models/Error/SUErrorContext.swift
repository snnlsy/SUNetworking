//
//  SUErrorContext.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SUErrorContext

/// Provides context for network errors.
public struct SUErrorContext {
    /// HTTP status code associated with the error.
    public let statusCode: Int?
    /// Detailed description of the error.
    public let message: String
    /// Underlying system error, if any.
    public let underlyingError: Error?
    
    /// Initializes a new ErrorContext instance.
    ///
    /// - Parameters:
    ///   - message: Error message.
    ///   - statusCode: HTTP status code.
    ///   - underlyingError: Underlying system error.
    public init(
        message: String,
        statusCode: Int? = nil,
        underlyingError: Error? = nil
    ) {
        self.message = message
        self.statusCode = statusCode
        self.underlyingError = underlyingError
    }
}
