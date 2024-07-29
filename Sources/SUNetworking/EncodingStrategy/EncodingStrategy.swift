//
//  EncodingStrategy.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - EncodingStrategy

/// Defines the strategy for determining the encoding type of a request.
public protocol EncodingStrategy {
    /// Determines the encoding type for a given request.
    ///
    /// - Parameter request: The URLRequestable object.
    /// - Returns: The NetworkEncoding type for the request.
    func determineEncoding(for request: URLRequestable) -> NetworkEncoding
}
