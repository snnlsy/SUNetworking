//
//  SUHeaderMergeStrategy.swift
//  SUNetworking
//
//  Created by SUNetworking
//

import Foundation

// MARK: - SUHeaderMergeStrategy

/// Defines how headers should be merged.
public enum SUHeaderMergeStrategy {
    /// Request headers override default headers.
    case requestOverridesDefault
    /// Default headers override request headers.
    case defaultOverridesRequest
    /// Merge both, with request taking precedence for conflicts.
    case merge
}

// MARK: - SUHeaderMerger

/// Handles merging of headers from multiple sources.
public struct SUHeaderMerger {
    private let strategy: SUHeaderMergeStrategy
    
    public init(strategy: SUHeaderMergeStrategy = .requestOverridesDefault) {
        self.strategy = strategy
    }
    
    /// Merges default and request headers according to the strategy.
    ///
    /// - Parameters:
    ///   - defaultHeaders: Headers from default provider.
    ///   - requestHeaders: Headers from the request.
    /// - Returns: Merged headers dictionary.
    public func merge(
        defaultHeaders: [String: String],
        requestHeaders: [String: String]?
    ) -> [String: String] {
        guard let requestHeaders = requestHeaders else {
            return defaultHeaders
        }
        
        switch strategy {
        case .requestOverridesDefault, .merge:
            return mergeCaseInsensitive(base: defaultHeaders, override: requestHeaders)
        case .defaultOverridesRequest:
            return mergeCaseInsensitive(base: requestHeaders, override: defaultHeaders)
        }
    }
    
    /// Merges headers with case-insensitive key handling.
    private func mergeCaseInsensitive(base: [String: String], override: [String: String]) -> [String: String] {
        var result = base
        for (key, value) in override {
            if let existingKey = result.keys.first(where: { $0.lowercased() == key.lowercased() }) {
                result.removeValue(forKey: existingKey)
            }
            result[key] = value
        }
        return result
    }
}
