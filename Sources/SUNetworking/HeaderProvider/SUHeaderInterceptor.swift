//
//  SUHeaderInterceptor.swift
//  SUNetworking
//
//  Created by SUNetworking
//

import Foundation

// MARK: - SUHeaderInterceptor

/// Protocol for intercepting and modifying headers before request execution.
public protocol SUHeaderInterceptor {
    /// Priority for interceptor execution. Higher values execute first.
    var priority: Int { get }
    
    /// If true, interceptor failure will fail the entire request.
    var isCritical: Bool { get }
    
    /// Intercepts and potentially modifies headers.
    ///
    /// - Parameter headers: Current headers dictionary.
    /// - Returns: Modified headers dictionary.
    /// - Throws: Error if interception fails.
    func intercept(headers: [String: String]) async throws -> [String: String]
}

public extension SUHeaderInterceptor {
    var isCritical: Bool { false }
}

// MARK: - SUAuthenticationInterceptor

/// Interceptor for adding authentication tokens to requests.
open class SUAuthenticationInterceptor: SUHeaderInterceptor {
    private let tokenProvider: () async -> String?
    private let headerKey: String
    private let tokenPrefix: String
    
    public var priority: Int { 100 }
    public var isCritical: Bool { true }
    
    public init(
        headerKey: String = "Authorization",
        tokenPrefix: String = "Bearer",
        tokenProvider: @escaping () async -> String?
    ) {
        self.headerKey = headerKey
        self.tokenPrefix = tokenPrefix
        self.tokenProvider = tokenProvider
    }
    
    open func intercept(headers: [String: String]) async throws -> [String: String] {
        var modifiedHeaders = headers
        
        if let token = await tokenProvider() {
            let prefix = tokenPrefix.trimmingCharacters(in: .whitespaces)
            modifiedHeaders[headerKey] = prefix.isEmpty ? token : "\(prefix) \(token)"
        }
        
        return modifiedHeaders
    }
}
