//
//  NetworkError.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - Error Handling

/// Represents various network-related errors.
public enum NetworkError: Error {
    /// Error for invalid URL.
    case invalidURL(ErrorContext)
    /// Error during request serialization.
    case serializationError(ErrorContext)
    /// Client-side error (4xx status codes).
    case clientError(ErrorContext)
    /// Server-side error (5xx status codes).
    case serverError(ErrorContext)
    /// Invalid response from the server.
    case invalidResponse(ErrorContext)
    /// Error during response parsing.
    case parsingError(ErrorContext)
    /// Network unavailable error.
    case networkUnavailable(ErrorContext)
    /// Request timeout error.
    case requestTimeout(ErrorContext)
    /// General network failure.
    case networkFailed(Error)
    /// Unexpected error.
    case unexpectedError(ErrorContext)
}
