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
        var attempt = 0
        let maxAttempts = request.retryConfig.maxRetries + 1
        
        while attempt < maxAttempts {
            let result = await operation()
            
            switch result {
            case .success:
                return result
            case .failure(let error):
                if !request.retryConfig.shouldRetry(error) {
                    return .failure(error)
                }
                
                if attempt >= request.retryConfig.maxRetries {
                    return .failure(.maxRetriesExceeded(SUErrorContext(
                        message: "Max retries (\(request.retryConfig.maxRetries)) exceeded",
                        underlyingError: error
                    )))
                }
                
                do {
                    let delay = request.retryConfig.delay(for: attempt)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } catch {
                    return .failure(.retryFailed(SUErrorContext(
                        message: "Retry operation interrupted",
                        underlyingError: error
                    )))
                }
                
                attempt += 1
            }
        }
        
        fatalError("Unreachable: retry loop should always return within the loop")
    }
}

