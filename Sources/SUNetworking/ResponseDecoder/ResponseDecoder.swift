//
//  ResponseDecoder.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - ResponseDecoder

/// Defines the decoding of network responses.
public protocol ResponseDecoder {
    /// Decodes data into a specified Decodable type.
    ///
    /// - Parameter data: The data to decode.
    /// - Returns: A Result containing either the decoded object or a NetworkError.
    func decode<T: Decodable>(_ data: Data) -> Result<T, NetworkError>
}
