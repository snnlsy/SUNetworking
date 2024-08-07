//
//  SUURLRequestable.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SUURLRequestable

/// Defines the requirements for objects that can be converted to URLRequests.
public protocol SUURLRequestable {
    /// The base URL for the request.
    var baseURL: URL { get }
    /// The path component of the URL.
    var path: String { get }
    /// The HTTP method for the request.
    var method: SUHTTPMethod { get }
    /// Optional headers for the request.
    var headers: [String: String]? { get }
    /// Optional parameters for the request.
    var parameters: Encodable? { get }
    /// The encoding type for the request.
    var encoding: SUNetworkEncoding { get }
    /// Configuration for request retries.
    var retryConfig: SURetryConfiguration { get }
}

public extension SUURLRequestable {
    var headers: [String: String]? { nil }
    var parameters: Encodable? { nil }
    var encoding: SUNetworkEncoding { .url }
    var retryConfig: SURetryConfiguration { SURetryConfiguration() }
}
