//
//  URLRequestable.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - URLRequestable

/// Defines the requirements for objects that can be converted to URLRequests.
public protocol URLRequestable {
    /// The base URL for the request.
    var baseURL: URL { get }
    /// The path component of the URL.
    var path: String { get }
    /// The HTTP method for the request.
    var method: HTTPMethod { get }
    /// Optional headers for the request.
    var headers: [String: String]? { get }
    /// Optional parameters for the request.
    var parameters: Encodable? { get }
    /// The encoding type for the request.
    var encoding: NetworkEncoding { get }
    /// Configuration for request retries.
    var retryConfig: RetryConfiguration { get }
}

public extension URLRequestable {
    var headers: [String: String]? { nil }
    var parameters: Encodable? { nil }
    var encoding: NetworkEncoding { .url }
    var retryConfig: RetryConfiguration { RetryConfiguration() }
}
