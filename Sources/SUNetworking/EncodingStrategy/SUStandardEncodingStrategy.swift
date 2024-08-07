//
//  SUStandardEncodingStrategy.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SUStandardEncodingStrategy

/// Standard implementation of EncodingStrategy.
open class SUStandardEncodingStrategy: SUEncodingStrategy {
    public init() {}
    
    /// Determines the encoding type for a given request.
    ///
    /// - Parameter request: The SUURLRequestable object.
    /// - Returns: The SUNetworkEncoding type for the request.
    open func determineEncoding(for request: SUURLRequestable) -> SUNetworkEncoding {
        request.encoding
    }
}
