//
//  HeaderUsageExample.swift
//  SUNetworking
//
//  Created by SUNetworking
//

import Foundation

// MARK: - Example 1: Basic Usage with Default Headers

class BasicHeaderExample {
    func setup() {
        // Default configuration includes User-Agent, Accept-Language, Accept
        let networkService = SUNetworkService()
        
        // All requests will automatically include default headers
    }
}

// MARK: - Example 2: Custom Header Provider

class CustomHeaderProvider: SUHeaderProvider {
    func defaultHeaders() -> [String: String] {
        return [
            "User-Agent": "MyApp/2.0",
            "Accept-Language": "en-US",
            "Accept": "application/json",
            "X-API-Version": "v2"
        ]
    }
}

class CustomHeaderExample {
    func setup() {
        let customProvider = CustomHeaderProvider()
        let sessionConfigurator = SUSessionConfigurator(headerProvider: customProvider)
        let networkService = SUNetworkService(sessionConfigurator: sessionConfigurator)
    }
}

// MARK: - Example 3: Authentication Interceptor

class AuthenticationExample {
    func setup() {
        // Create authentication interceptor
        let authInterceptor = SUAuthenticationInterceptor { 
            // Fetch token from secure storage
            return await self.getAuthToken()
        }
        
        let networkService = SUNetworkService(headerInterceptors: [authInterceptor])
        
        // All requests will automatically include Authorization header
    }
    
    private func getAuthToken() async -> String? {
        // Implement token retrieval logic
        return "your_token_here"
    }
}

// MARK: - Example 4: Custom Interceptor

class CustomLoggingInterceptor: SUHeaderInterceptor {
    var priority: Int { 50 }
    
    func intercept(headers: [String: String]) async throws -> [String: String] {
        var modifiedHeaders = headers
        modifiedHeaders["X-Request-ID"] = UUID().uuidString
        modifiedHeaders["X-Timestamp"] = "\(Date().timeIntervalSince1970)"
        return modifiedHeaders
    }
}

class MultipleInterceptorsExample {
    func setup() {
        let authInterceptor = SUAuthenticationInterceptor { 
            return await self.getAuthToken()
        }
        
        let loggingInterceptor = CustomLoggingInterceptor()
        
        let networkService = SUNetworkService(
            headerInterceptors: [authInterceptor, loggingInterceptor]
        )
    }
    
    private func getAuthToken() async -> String? {
        return "token"
    }
}

// MARK: - Example 5: Request-Specific Headers

struct AuthenticatedRequest: SUURLRequestable {
    let method: SUHTTPMethod = .get
    let path: String = "/user/profile"
    let baseURL: URL = URL(string: "https://api.example.com")!
    
    // Request-specific headers override defaults
    var headers: [String: String]? {
        return [
            "X-Custom-Header": "custom-value",
            "Content-Type": "application/json"
        ]
    }
}

// MARK: - Example 6: Complete Production Setup

class ProductionNetworkSetup {
    static func createNetworkService() -> SUNetworkService {
        // 1. Custom header provider
        let headerProvider = CustomHeaderProvider()
        
        // 2. Session configurator with headers
        let sessionConfigurator = SUSessionConfigurator(headerProvider: headerProvider)
        
        // 3. Authentication interceptor
        let authInterceptor = SUAuthenticationInterceptor(
            headerKey: "Authorization",
            tokenPrefix: "Bearer"
        ) {
            return await TokenManager.shared.getAccessToken()
        }
        
        // 4. Custom interceptors
        let requestIDInterceptor = CustomLoggingInterceptor()
        
        // 5. Create service with all components
        return SUNetworkService(
            sessionConfigurator: sessionConfigurator,
            headerInterceptors: [authInterceptor, requestIDInterceptor]
        )
    }
}

// Mock token manager
class TokenManager {
    static let shared = TokenManager()
    
    func getAccessToken() async -> String? {
        return "access_token"
    }
}
