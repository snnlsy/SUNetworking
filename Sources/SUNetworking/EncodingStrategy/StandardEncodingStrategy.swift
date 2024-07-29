//
//  StandardEncodingStrategy.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - StandardEncodingStrategy

/// Standard implementation of EncodingStrategy.
open class StandardEncodingStrategy: EncodingStrategy {
    public init() {}
    
    /// Determines the encoding type for a given request.
    ///
    /// - Parameter request: The URLRequestable object.
    /// - Returns: The NetworkEncoding type for the request.
    open func determineEncoding(for request: URLRequestable) -> NetworkEncoding {
        request.encoding
    }
}
