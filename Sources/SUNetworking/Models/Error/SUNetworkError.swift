//
//  SUNetworkError.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - Error Handling

/// Represents various network-related errors.
public enum SUNetworkError: Error {
    /// Error for invalid URL.
    case invalidURL(SUErrorContext)
    /// Error during request serialization.
    case serializationError(SUErrorContext)
    /// Client-side error (4xx status codes).
    case clientError(SUErrorContext)
    /// Server-side error (5xx status codes).
    case serverError(SUErrorContext)
    /// Invalid response from the server.
    case invalidResponse(SUErrorContext)
    /// Error during response parsing.
    case parsingError(SUErrorContext)
    /// Network unavailable error.
    case networkUnavailable(SUErrorContext)
    /// Request timeout error.
    case requestTimeout(SUErrorContext)
    /// General network failure.
    case networkFailed(Error)
    /// Unexpected error.
    case unexpectedError(SUErrorContext)
    /// Error when maximum number of retries is exceeded.
    case maxRetriesExceeded(SUErrorContext)
    /// Error when retry operation fails.
    case retryFailed(SUErrorContext)
}
