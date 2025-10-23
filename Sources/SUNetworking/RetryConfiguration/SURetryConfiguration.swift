//
//  SURetryConfiguration.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SURetryConfiguration

/// Configures the retry behavior for network requests.
public struct SURetryConfiguration {
    /// Maximum number of retry attempts.
    public let maxRetries: Int
    /// Initial delay for the first retry attempt.
    public let initialDelay: TimeInterval
    /// Whether to use exponential backoff for retry delays.
    public let useExponentialBackoff: Bool
    /// Closure to determine if a retry should be attempted based on the error.
    public let shouldRetry: (Error) -> Bool
    
    /// Initializes a new SURetryConfiguration instance.
    ///
    /// - Parameters:
    ///   - maxRetries: Maximum number of retry attempts.
    ///   - initialDelay: Initial delay for the first retry attempt.
    ///   - useExponentialBackoff: Whether to use exponential backoff (0.5s → 1s → 2s).
    ///   - shouldRetry: Closure to determine if a retry should be attempted.
    public init(
        maxRetries: Int = 2,
        initialDelay: TimeInterval = 0.5,
        useExponentialBackoff: Bool = true,
        shouldRetry: @escaping (Error) -> Bool = { _ in true }
    ) {
        self.maxRetries = maxRetries
        self.initialDelay = initialDelay
        self.useExponentialBackoff = useExponentialBackoff
        self.shouldRetry = shouldRetry
    }
    
    /// Calculates the delay for a specific retry attempt.
    ///
    /// - Parameter attempt: The retry attempt number (0-based).
    /// - Returns: The delay in seconds for the given attempt.
    public func delay(for attempt: Int) -> TimeInterval {
        guard useExponentialBackoff else { return initialDelay }
        return initialDelay * pow(2.0, Double(attempt))
    }
}
