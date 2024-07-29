//
//  URLRequestBuilder.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - URLRequestBuilder

/// Builds URLRequests from URLRequestable objects.
open class URLRequestBuilder: URLRequestBuilding {
    private let encodingStrategy: EncodingStrategy
    
    /// Initializes a new URLRequestBuilder instance.
    ///
    /// - Parameter encodingStrategy: The strategy for determining request encoding.
    public init(encodingStrategy: EncodingStrategy = StandardEncodingStrategy()) {
        self.encodingStrategy = encodingStrategy
    }
    
    /// Creates a URLRequest from a URLRequestable object.
    ///
    /// - Parameter requestable: The URLRequestable object.
    /// - Returns: A Result containing either the URLRequest or a NetworkError.
    open func createRequest(from requestable: URLRequestable) -> Result<URLRequest, NetworkError> {
        let url = requestable.baseURL.appendingPathComponent(requestable.path)
        var request = URLRequest(url: url)
        request.httpMethod = requestable.method.rawValue
        request.allHTTPHeaderFields = requestable.headers
        
        let encoding = encodingStrategy.determineEncoding(for: requestable)
        
        switch encoding {
        case .url:
            return encodeURLParameters(
                request: &request,
                parameters: requestable.parameters
            )
        case .json:
            return encodeJSONParameters(
                request: &request,
                parameters: requestable.parameters
            )
        }
    }
    
    /// Encodes URL parameters for a request.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to modify.
    ///   - parameters: The parameters to encode.
    /// - Returns: A Result containing either the modified URLRequest or a NetworkError.
    private func encodeURLParameters(request: inout URLRequest, parameters: Encodable?) -> Result<URLRequest, NetworkError> {
        guard let parameters = parameters else {
            return .success(request)
        }
        guard let url = request.url else {
            return .failure(.invalidURL(ErrorContext(
                userMessage: "Invalid URL",
                statusCode: nil,
                errorDescription: "The URL provided was invalid"
            )))
        }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            do {
                let jsonData = try JSONEncoder().encode(parameters)
                let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                urlComponents.queryItems = jsonDict?.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = urlComponents.url
                return .success(request)
            } catch {
                return .failure(.serializationError(ErrorContext(
                    userMessage: "Failed to encode request parameters",
                    statusCode: nil,
                    errorDescription: "Error occurred during request serialization",
                    underlyingError: error
                )))
            }
        }
        return .success(request)
    }
    
    /// Encodes JSON parameters for a request.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to modify.
    ///   - parameters: The parameters to encode.
    /// - Returns: A Result containing either the modified URLRequest or a NetworkError.
    private func encodeJSONParameters(request: inout URLRequest, parameters: Encodable?) -> Result<URLRequest, NetworkError> {
        guard let parameters = parameters else { return .success(request) }
        do {
            let jsonData = try JSONEncoder().encode(parameters)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return .success(request)
        } catch {
            return .failure(.serializationError(ErrorContext(
                userMessage: "Failed to encode request parameters",
                statusCode: nil,
                errorDescription: "Error occurred during request serialization",
                underlyingError: error
            )))
        }
    }
}

