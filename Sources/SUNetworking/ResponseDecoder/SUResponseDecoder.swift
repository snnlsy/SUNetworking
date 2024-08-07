//
//  SUResponseDecoder.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SUResponseDecoder

/// Defines the decoding of network responses.
public protocol SUResponseDecoder {
    /// Decodes data into a specified Decodable type.
    ///
    /// - Parameter data: The data to decode.
    /// - Returns: A Result containing either the decoded object or a SUNetworkError.
    func decode<T: Decodable>(_ data: Data) -> Result<T, SUNetworkError>
}
