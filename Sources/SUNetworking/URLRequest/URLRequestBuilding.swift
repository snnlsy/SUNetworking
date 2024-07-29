//
//  URLRequestFactory.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - URLRequestFactory

/// Defines the factory for creating URLRequests.
public protocol URLRequestBuilding {
    /// Creates a URLRequest from a URLRequestable object.
    ///
    /// - Parameter requestable: The URLRequestable object.
    /// - Returns: A Result containing either the URLRequest or a NetworkError.
    func createRequest(from requestable: URLRequestable) -> Result<URLRequest, NetworkError>
}
