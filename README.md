# SUNetworking

SUNetworking is a powerful and flexible networking library for Swift applications, designed to simplify the process of making HTTP requests and handling responses. It provides a clean, protocol-oriented architecture that makes it easy to integrate into your iOS projects.

## Features

*   **Protocol-Oriented Design**: Easily extensible and customizable.
*   **Asynchronous Networking**: Built with Swift's modern concurrency features.
*   **Flexible Request Building**: Supports various HTTP methods and parameter encodings.
*   **Automatic Retry Mechanism**: Configurable retry logic for failed requests.
*   **Error Handling**: Comprehensive error types for different networking scenarios.
*   **Response Decoding**: Built-in JSON decoding with support for custom decoders.
*   **Session Configuration**: Customizable URLSession settings.
*   **Type-Safe Responses**: Generic response types for type-safe data handling.

## Requirements

*   iOS 13.0+

## Installation

### Swift Package Manager

You can add SUNetworking to your project using Swift Package Manager. In Xcode, go to File > Swift Packages > Add Package Dependency and enter the repository URL:

```
https://github.com/snnlsy/SUNetworking.git
```

## Usage

### Basic Request

```
import SUNetworking

struct User: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

struct ExampleRequest: SUURLRequestable {
    let method: SUHTTPMethod = .get
    let path: String = "/todos/1"
    let baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let req = ExampleRequest()
        let networkService: SUNetworkServicing = SUNetworkService()
        
        Task {
            let result: Result<User, SUNetworkError> = await networkService.execute(req)
            
            switch result {
            case .success(let user):
                print("User fetched successfully:")
                print("Title: \(user.title)")
            case .failure(let error):
                print("Error fetching user: \(error)")
            }
        }
    }
}

```

## Architecture

SUNetworking is built on a modular architecture:

*   `SUNetworkService`: The main service for executing network requests.
*   `SUURLRequestable`: Protocol for defining network requests.
*   `SUURLRequestBuilder`: Builds URLRequests from SUURLRequestable objects.
*   `SUSessionConfigurator`: Configures URLSession settings.
*   `SUResponseDecoder`: Handles decoding of network responses.
*   `SURetryConfiguration`: Configures retry behavior for requests.

## Customization

SUNetworking is designed to be highly customizable. You can extend or replace various components:

*   Create custom `URLRequestable` implementations for specific API endpoints.
*   Implement custom `SessionConfigurable` for tailored URLSession configurations.
*   Develop custom `ResponseDecoder` for handling different response formats.
*   Extend `EncodingStrategy` for custom parameter encoding logic.

## Contributing

Contributions to SUNetworking are welcome! Please feel free to submit a Pull Request.

## License

SUNetworking is released under the MIT license. See [LICENSE](LICENSE) for details.
