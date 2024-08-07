//
//  SUHTTPMethod.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - HTTP Method

/// Represents HTTP methods for network requests.
public enum SUHTTPMethod: String {
    /// GET method for retrieving resources.
    case get = "GET"
    /// POST method for submitting data.
    case post = "POST"
    /// PUT method for updating existing resources.
    case put = "PUT"
    /// DELETE method for removing resources.
    case delete = "DELETE"
    /// PATCH method for partially modifying resources.
    case patch = "PATCH"
}
