//
//  SUHeaderConfiguration.swift
//  SUNetworking
//
//  Created by SUNetworking
//

import Foundation

// MARK: - SUHeaderConfiguration

/// Configuration for header management in network requests.
public struct SUHeaderConfiguration {
    public let provider: SUHeaderProvider?
    public let mergeStrategy: SUHeaderMergeStrategy
    public let interceptors: [SUHeaderInterceptor]
    public let validateHeaders: Bool
    
    public init(
        provider: SUHeaderProvider? = SUDefaultHeaderProvider(),
        mergeStrategy: SUHeaderMergeStrategy = .requestOverridesDefault,
        interceptors: [SUHeaderInterceptor] = [],
        validateHeaders: Bool = true
    ) {
        self.provider = provider
        self.mergeStrategy = mergeStrategy
        self.interceptors = interceptors
        self.validateHeaders = validateHeaders
    }
    
    /// Default configuration with standard settings.
    public static var `default`: SUHeaderConfiguration {
        SUHeaderConfiguration()
    }
}
