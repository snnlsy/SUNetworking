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

// MARK: - CustomStringConvertible

extension SUNetworkError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidURL(let context):
            return format("Invalid URL", context)
        case .serializationError(let context):
            return format("Serialization Error", context)
        case .clientError(let context):
            return format("Client Error", context)
        case .serverError(let context):
            return format("Server Error", context)
        case .invalidResponse(let context):
            return format("Invalid Response", context)
        case .parsingError(let context):
            return format("Parsing Error", context)
        case .networkUnavailable(let context):
            return format("Network Unavailable", context)
        case .requestTimeout(let context):
            return format("Request Timeout", context)
        case .networkFailed(let error):
            return "Network Failed: \((error as NSError).localizedDescription)"
        case .unexpectedError(let context):
            return format("Unexpected Error", context)
        case .maxRetriesExceeded(let context):
            return format("Max Retries Exceeded", context)
        case .retryFailed(let context):
            return format("Retry Failed", context)
        }
    }
    
    public var icon: String {
        "❌"
    }

    private func format(_ type: String, _ context: SUErrorContext) -> String {
        if let statusCode = context.statusCode {
            return "\(type) [\(statusCode)]: \(context.message)"
        }
        return "\(type): \(context.message)"
    }
}
