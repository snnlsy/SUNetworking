//
//  SUNetworkServicing.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - NetworkServicing

/// Defines the execution of network requests.
public protocol SUNetworkServicing {
    /// Executes a network request and returns a decoded response.
    ///
    /// - Parameter request: The SUURLRequestable object.
    /// - Returns: A Result containing either the decoded response or a SUNetworkError.
    func execute<T: Decodable>(_ request: SUURLRequestable) async -> Result<T, SUNetworkError>
}
