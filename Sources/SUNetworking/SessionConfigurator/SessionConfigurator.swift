//
//  SessionConfigurator.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SessionConfigurator

/// Standard implementation of SessionConfigurable.
open class SessionConfigurator: SessionConfigurable {
    public init() {}
    
    /// Creates a URLSessionConfiguration with default settings.
    ///
    /// - Returns: A configured URLSessionConfiguration instance.
    open func createConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 30.0
        return configuration
    }
}
