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
    /// User-friendly error message.
    public let userMessage: String?
    /// HTTP status code associated with the error.
    public let statusCode: Int?
    /// Detailed description of the error.
    public let errorDescription: String?
    /// Underlying system error, if any.
    public let underlyingError: Error?
    
    /// Creates a generic error context.
    public static var generic: Self {
        .init(
            userMessage: "An unexpected error occurred. Please try again.",
            statusCode: nil,
            errorDescription: nil,
            underlyingError: nil
        )
    }
    
    /// Initializes a new ErrorContext instance.
    ///
    /// - Parameters:
    ///   - userMessage: User-friendly error message.
    ///   - statusCode: HTTP status code.
    ///   - errorDescription: Detailed error description.
    ///   - underlyingError: Underlying system error.
    public init(
        userMessage: String?,
        statusCode: Int?,
        errorDescription: String?,
        underlyingError: Error? = nil
    ) {
        self.userMessage = userMessage
        self.statusCode = statusCode
        self.errorDescription = errorDescription
        self.underlyingError = underlyingError
    }
}
