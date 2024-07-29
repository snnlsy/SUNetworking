//
//  SessionConfigurable.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SessionConfigurable

/// Defines the configuration for URLSessions.
public protocol SessionConfigurable {
    /// Creates a URLSessionConfiguration.
    ///
    /// - Returns: A configured URLSessionConfiguration instance.
    func createConfiguration() -> URLSessionConfiguration
}
