//
//  HeaderConfigurationExample.swift
//  SUNetworking
//
//  Example demonstrating proper header configuration
//

import Foundation
import SUNetworking

// MARK: - Example 1: Basic Usage with Default Headers

func basicHeaderExample() {
    let networkService = SUNetworkService()
    
    Task {
        let request = ExampleRequest()
        let result: Result<User, SUNetworkError> = await networkService.execute(request)
        // Default headers (User-Agent, Accept, Accept-Language) are automatically applied
    }
}

// MARK: - Example 2: Custom Header Provider

class CustomHeaderProvider: SUHeaderProvider {
    func defaultHeaders() -> [String: String] {
        return [
            "User-Agent": "MyApp/2.0",
            "Accept": "application/json",
            "X-API-Version": "v1"
        ]
    }
}

func customHeaderProviderExample() {
    let configuration = SUHeaderConfiguration(
        provider: CustomHeaderProvider()
    )
    
    let networkService = SUNetworkService(headerConfiguration: configuration)
}

// MARK: - Example 3: Authentication with Interceptor

func authenticationExample() {
    let authInterceptor = SUAuthenticationInterceptor { 
        // Fetch token from secure storage
        return await TokenManager.shared.getToken()
    }
    
    let configuration = SUHeaderConfiguration(
        interceptors: [authInterceptor]
    )
    
    let networkService = SUNetworkService(headerConfiguration: configuration)
}

// MARK: - Example 4: Custom Interceptor

class CustomHeaderInterceptor: SUHeaderInterceptor {
    var priority: Int { 50 }
    
    func intercept(headers: [String: String]) async throws -> [String: String] {
        var modified = headers
        modified["X-Request-ID"] = UUID().uuidString
        modified["X-Timestamp"] = "\(Date().timeIntervalSince1970)"
        return modified
    }
}

func customInterceptorExample() {
    let configuration = SUHeaderConfiguration(
        interceptors: [CustomHeaderInterceptor()]
    )
    
    let networkService = SUNetworkService(headerConfiguration: configuration)
}

// MARK: - Example 5: Multiple Interceptors with Priority

func multipleInterceptorsExample() {
    let authInterceptor = SUAuthenticationInterceptor { 
        return await TokenManager.shared.getToken()
    }
    // Auth interceptor has priority 100 (executes first)
    
    let customInterceptor = CustomHeaderInterceptor()
    // Custom interceptor has priority 50 (executes second)
    
    let configuration = SUHeaderConfiguration(
        interceptors: [customInterceptor, authInterceptor] // Order doesn't matter, priority does
    )
    
    let networkService = SUNetworkService(headerConfiguration: configuration)
}

// MARK: - Example 6: Header Merge Strategies

func mergStrategyExample() {
    // Request headers override defaults
    let config1 = SUHeaderConfiguration(
        mergeStrategy: .requestOverridesDefault
    )
    
    // Default headers override request
    let config2 = SUHeaderConfiguration(
        mergeStrategy: .defaultOverridesRequest
    )
    
    // Merge both (request takes precedence on conflicts)
    let config3 = SUHeaderConfiguration(
        mergeStrategy: .merge
    )
}

// MARK: - Example 7: Request-Specific Headers

struct AuthenticatedRequest: SUURLRequestable {
    let baseURL: URL = URL(string: "https://api.example.com")!
    let path: String = "/user/profile"
    let method: SUHTTPMethod = .get
    
    // These headers will be merged with default headers
    var headers: [String: String]? {
        return [
            "X-Custom-Header": "CustomValue",
            "Accept": "application/vnd.api+json" // Overrides default Accept header
        ]
    }
}

// MARK: - Example 8: Disable Header Validation

func disableValidationExample() {
    let configuration = SUHeaderConfiguration(
        validateHeaders: false // Allow any headers (not recommended for production)
    )
    
    let networkService = SUNetworkService(headerConfiguration: configuration)
}

// MARK: - Supporting Types

struct User: Codable {
    let id: Int
    let name: String
}

struct ExampleRequest: SUURLRequestable {
    let baseURL: URL = URL(string: "https://api.example.com")!
    let path: String = "/users/1"
    let method: SUHTTPMethod = .get
}

actor TokenManager {
    static let shared = TokenManager()
    
    func getToken() async -> String? {
        return "sample_token_123"
    }
}
