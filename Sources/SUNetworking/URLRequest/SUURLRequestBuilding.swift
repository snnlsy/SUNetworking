//
//  SUURLRequestBuilding.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SUURLRequestBuilding

/// Defines the factory for creating URLRequests.
public protocol SUURLRequestBuilding {
    /// Creates a URLRequest from a URLRequestable object.
    ///
    /// - Parameter requestable: The SUURLRequestable object.
    /// - Returns: A Result containing either the URLRequest or a SUNetworkError.
    func createRequest(from requestable: SUURLRequestable) -> Result<URLRequest, SUNetworkError>
}
