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
    /// Delay between retry attempts.
    public let retryDelay: TimeInterval
    /// Closure to determine if a retry should be attempted based on the error.
    public let shouldRetry: (Error) -> Bool
    
    /// Initializes a new SURetryConfiguration instance.
    ///
    /// - Parameters:
    ///   - maxRetries: Maximum number of retry attempts.
    ///   - retryDelay: Delay between retry attempts.
    ///   - shouldRetry: Closure to determine if a retry should be attempted.
    public init(
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1.0,
        shouldRetry: @escaping (Error) -> Bool = { _ in true }
    ) {
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
        self.shouldRetry = shouldRetry
    }
}
