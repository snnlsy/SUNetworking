//
//  File.swift
//  
//
//  Created by SUlusoy on 19.08.2024.
//

import Foundation

extension SUNetworkService {
    /// Retries an asynchronous operation based on the request's retry configuration.
    ///
    /// - Parameters:
    ///   - request: The `SUURLRequestable` containing retry settings.
    ///   - operation: The async operation to perform, returning `Result<T, SUNetworkError>`.
    /// - Returns: A `Result` with either the operation's success or a `SUNetworkError`.
    func retryOperation<T>(
        request: SUURLRequestable,
        operation: @escaping () async -> Result<T, SUNetworkError>
    ) async -> Result<T, SUNetworkError> {
        var retries = 0
        while retries <= request.retryConfig.maxRetries {
            let result = await operation()
            switch result {
            case .success:
                return result
            case .failure(let error):
                if !request.retryConfig.shouldRetry(error) {
                    return .failure(error)
                }
                retries += 1
                if retries > request.retryConfig.maxRetries {
                    return .failure(.maxRetriesExceeded(SUErrorContext(
                        userMessage: "The operation couldn't be completed after multiple attempts. Please try again later.",
                        statusCode: nil,
                        errorDescription: "Maximum number of retries (\(request.retryConfig.maxRetries)) exceeded",
                        underlyingError: error
                    )))
                }
                do {
                    try await Task.sleep(nanoseconds: UInt64(request.retryConfig.retryDelay * 1_000_000_000))
                } catch {
                    return .failure(.retryFailed(SUErrorContext(
                        userMessage: "An error occurred while retrying the operation. Please try again.",
                        statusCode: nil,
                        errorDescription: "Retry operation failed due to an unexpected error during sleep",
                        underlyingError: error
                    )))
                }
            }
        }
        
        return .failure(.unexpectedError(SUErrorContext(
            userMessage: "An unexpected error occurred. Please try again.",
            statusCode: nil,
            errorDescription: "Unexpected flow in retry operation",
            underlyingError: nil
        )))
    }
}

