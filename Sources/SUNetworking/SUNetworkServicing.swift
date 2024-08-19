//
//  SUNetworkServicing.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation
import Combine

// MARK: - NetworkServicing

/// Defines the execution of network requests.
public protocol SUNetworkServicing {
    /// Executes a network request asynchronously and returns the decoded response.
    ///
    /// - Parameter request: The `SUURLRequestable` containing request details.
    /// - Returns: A `Result` containing either the decoded response or a `SUNetworkError`.
    func execute<T: Decodable>(_ request: SUURLRequestable) async -> Result<T, SUNetworkError>

    /// Executes a network request and returns a decoded response as a `Publisher`.
    ///
    /// - Parameter request: The `SUURLRequestable` containing request details.
    /// - Returns: A `Publisher` that emits the decoded response or a `SUNetworkError`.
    func execute<T: Decodable>(_ request: SUURLRequestable) -> AnyPublisher<T, SUNetworkError>
}
