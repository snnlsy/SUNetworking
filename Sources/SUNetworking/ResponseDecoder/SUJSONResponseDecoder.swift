//
//  SUJSONResponseDecoder.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SUJSONResponseDecoder

/// Decodes JSON responses.
open class SUJSONResponseDecoder: SUResponseDecoder {
    private let decoder: JSONDecoder
    
    /// Initializes a new SUJSONResponseDecoder instance.
    ///
    /// - Parameter decoder: The JSONDecoder to use for decoding.
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    /// Decodes JSON data into a specified Decodable type.
    ///
    /// - Parameter data: The JSON data to decode.
    /// - Returns: A Result containing either the decoded object or a SUNetworkError.
    open func decode<T: Decodable>(_ data: Data) -> Result<T, SUNetworkError> {
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(.parsingError(SUErrorContext(
                userMessage: "Failed to parse server response",
                statusCode: nil,
                errorDescription: "Error occurred while parsing the response",
                underlyingError: error
            )))
        }
    }
}

