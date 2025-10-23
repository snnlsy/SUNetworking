//
//  SUHeaderProvider.swift
//  SUNetworking
//
//  Created by SUNetworking
//

import Foundation

// MARK: - SUHeaderProvider

/// Protocol for providing default HTTP headers.
public protocol SUHeaderProvider {
    /// Returns default headers to be included in all requests.
    func defaultHeaders() -> [String: String]
}

// MARK: - SUDefaultHeaderProvider

/// Standard implementation providing common default headers.
open class SUDefaultHeaderProvider: SUHeaderProvider {
    private let userAgent: String
    private let acceptLanguage: String
    private let accept: String
    
    public init(
        userAgent: String = "SUNetworking/1.0",
        acceptLanguage: String = Locale.preferredLanguages.first ?? "en",
        accept: String = "application/json"
    ) {
        self.userAgent = userAgent
        self.acceptLanguage = acceptLanguage
        self.accept = accept
    }
    
    open func defaultHeaders() -> [String: String] {
        return [
            "User-Agent": userAgent,
            "Accept-Language": acceptLanguage,
            "Accept": accept
        ]
    }
}
