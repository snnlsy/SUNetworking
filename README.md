# SUNetworking

A modern, Swift-based networking library that provides a clean and flexible API for making HTTP requests with support for async/await and Combine.

## Features

- ✅ **Modern Swift Concurrency** - Full support for async/await and Combine
- 🔄 **Automatic Retry Logic** - Configurable retry mechanism with exponential backoff
- 🔐 **Header Management** - Flexible header configuration with interceptors
- 🎯 **Type-Safe Requests** - Protocol-based request definitions
- 📦 **Codable Support** - Automatic JSON encoding/decoding
- 🛡️ **Error Handling** - Comprehensive error types with context
- 🔌 **Extensible Architecture** - Easy to customize and extend

## Requirements

- iOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add SUNetworking to your project via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SUNetworking.git", from: "1.0.0")
]
```

## Quick Start

### 1. Define Your Request

```swift
struct GetUserRequest: SUURLRequestable {
    let baseURL = URL(string: "https://api.example.com")!
    let path = "/users/1"
    let method: SUHTTPMethod = .get
}
```

### 2. Create Network Service

```swift
let networkService = SUNetworkService()
```

### 3. Execute Request

**Using async/await:**

```swift
let result: Result<User, SUNetworkError> = await networkService.execute(GetUserRequest())

switch result {
case .success(let user):
    print("User: \(user.name)")
case .failure(let error):
    print("Error: \(error)")
}
```

**Using Combine:**

```swift
networkService.execute(GetUserRequest())
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error: \(error)")
            }
        },
        receiveValue: { (user: User) in
            print("User: \(user.name)")
        }
    )
    .store(in: &cancellables)
```

## Advanced Usage

### POST Request with Parameters

```swift
struct CreateUserRequest: SUURLRequestable {
    let baseURL = URL(string: "https://api.example.com")!
    let path = "/users"
    let method: SUHTTPMethod = .post
    let encoding: SUNetworkEncoding = .json
    
    var parameters: Encodable? {
        return User(name: "John Doe", email: "john@example.com")
    }
}
```

### Custom Headers

```swift
struct AuthenticatedRequest: SUURLRequestable {
    let baseURL = URL(string: "https://api.example.com")!
    let path = "/user/profile"
    let method: SUHTTPMethod = .get
    
    var headers: [String: String]? {
        return [
            "Authorization": "Bearer \(token)",
            "X-Custom-Header": "CustomValue"
        ]
    }
}
```

### Header Interceptors

Create dynamic headers that are applied to all requests:

```swift
let authInterceptor = SUAuthenticationInterceptor { 
    return await TokenManager.shared.getToken()
}

let networkService = SUNetworkService(
    headerInterceptors: [authInterceptor]
)
```

### Custom Header Provider

```swift
class CustomHeaderProvider: SUHeaderProvider {
    func defaultHeaders() -> [String: String] {
        return [
            "User-Agent": "MyApp/2.0",
            "Accept": "application/json",
            "X-API-Version": "v1"
        ]
    }
}

let configuration = SUHeaderConfiguration(
    provider: CustomHeaderProvider()
)

let networkService = SUNetworkService(
    headerConfiguration: configuration
)
```

### Retry Configuration

```swift
struct RetryableRequest: SUURLRequestable {
    let baseURL = URL(string: "https://api.example.com")!
    let path = "/data"
    let method: SUHTTPMethod = .get
    
    var retryConfig: SURetryConfiguration {
        SURetryConfiguration(
            maxRetries: 3,
            initialDelay: 1.0,
            useExponentialBackoff: true,
            shouldRetry: { error in
                // Custom retry logic
                return true
            }
        )
    }
}
```

### Custom Response Decoder

```swift
class CustomResponseDecoder: SUResponseDecoder {
    func decode<T: Decodable>(_ data: Data) -> Result<T, SUNetworkError> {
        // Custom decoding logic
    }
}

let networkService = SUNetworkService(
    responseDecoder: CustomResponseDecoder()
)
```

## Architecture

### Core Components

- **SUNetworkService** - Main service for executing network requests
- **SUURLRequestable** - Protocol defining request requirements
- **SUHeaderConfiguration** - Manages header configuration and interceptors
- **SURetryConfiguration** - Configures retry behavior
- **SUResponseDecoder** - Handles response decoding
- **SUNetworkError** - Comprehensive error types

### Header Management

SUNetworking provides a flexible header management system:

1. **Default Headers** - Automatically applied to all requests
2. **Request Headers** - Specific to individual requests
3. **Header Interceptors** - Dynamic headers with priority-based execution
4. **Merge Strategies** - Control how headers are combined

### Error Handling

```swift
public enum SUNetworkError: Error {
    case invalidURL(SUErrorContext)
    case invalidResponse(SUErrorContext)
    case networkFailed(Error)
    case decodingFailed(SUErrorContext)
    case clientError(SUErrorContext)
    case serverError(SUErrorContext)
    case unexpectedError(SUErrorContext)
}
```

## Examples

Check the `Examples/` folder for more detailed usage examples:

- `HeaderConfigurationExample.swift` - Header configuration patterns
- `HeaderUsageExample.swift` - Practical header usage scenarios

## License

This project is available under the MIT license.

## Author

Sinan Ulusoy

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
