//
//  SUEncodingStrategy.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SUEncodingStrategy

/// Defines the strategy for determining the encoding type of a request.
public protocol SUEncodingStrategy {
    /// Determines the encoding type for a given request.
    ///
    /// - Parameter request: The SUURLRequestable object.
    /// - Returns: The SUNetworkEncoding type for the request.
    func determineEncoding(for request: SUURLRequestable) -> SUNetworkEncoding
}
