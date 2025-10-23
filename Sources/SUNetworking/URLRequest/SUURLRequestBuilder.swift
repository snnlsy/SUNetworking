//
//  SUURLRequestBuilder.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - SUURLRequestBuilder

/// Builds URLRequests from URLRequestable objects.
open class SUURLRequestBuilder: SUURLRequestBuilding {
    private let encodingStrategy: SUEncodingStrategy
    private let headerMerger: SUHeaderMerger
    private let headerInterceptors: [SUHeaderInterceptor]
    private let headerProvider: SUHeaderProvider?
    private let validateHeaders: Bool
    
    /// Initializes a new SUURLRequestBuilder instance.
    ///
    /// - Parameters:
    ///   - encodingStrategy: The strategy for determining request encoding.
    ///   - headerMerger: Strategy for merging headers.
    ///   - headerInterceptors: Array of header interceptors.
    ///   - headerProvider: Provider for default headers.
    ///   - validateHeaders: Whether to validate headers.
    public init(
        encodingStrategy: SUEncodingStrategy = SUStandardEncodingStrategy(),
        headerMerger: SUHeaderMerger = SUHeaderMerger(),
        headerInterceptors: [SUHeaderInterceptor] = [],
        headerProvider: SUHeaderProvider? = SUDefaultHeaderProvider(),
        validateHeaders: Bool = true
    ) {
        self.encodingStrategy = encodingStrategy
        self.headerMerger = headerMerger
        self.headerInterceptors = headerInterceptors.sorted { $0.priority > $1.priority }
        self.headerProvider = headerProvider
        self.validateHeaders = validateHeaders
    }
    
    /// Creates a URLRequest from a URLRequestable object.
    ///
    /// - Parameter requestable: The SUURLRequestable object.
    /// - Returns: A Result containing either the URLRequest or a SUNetworkError.
    open func createRequest(from requestable: SUURLRequestable) async -> Result<URLRequest, SUNetworkError> {
        let url = requestable.baseURL.appendingPathComponent(requestable.path)
        var request = URLRequest(url: url)
        request.httpMethod = requestable.method.rawValue
        request.timeoutInterval = 60
        request.cachePolicy = .useProtocolCachePolicy
        
        let encoding = encodingStrategy.determineEncoding(for: requestable)
        
        let headersResult = await buildHeaders(for: requestable, encoding: encoding)
        switch headersResult {
        case .success(let headers):
            request.allHTTPHeaderFields = headers
        case .failure(let error):
            return .failure(error)
        }
        
        switch encoding {
        case .url:
            return encodeURLParameters(request: &request, parameters: requestable.parameters)
        case .json:
            return encodeJSONParameters(request: &request, parameters: requestable.parameters)
        }
    }
    
    /// Encodes URL parameters for a request.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to modify.
    ///   - parameters: The parameters to encode.
    /// - Returns: A Result containing either the modified URLRequest or a SUNetworkError.
    private func encodeURLParameters(request: inout URLRequest, parameters: Encodable?) -> Result<URLRequest, SUNetworkError> {
        guard let parameters = parameters else {
            return .success(request)
        }
        guard let url = request.url else {
            return .failure(.invalidURL(SUErrorContext(message: "Invalid URL")))
        }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            do {
                let jsonData = try JSONEncoder().encode(parameters)
                let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                urlComponents.queryItems = jsonDict?.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = urlComponents.url
                return .success(request)
            } catch {
                return .failure(.serializationError(SUErrorContext(
                    message: "Failed to encode URL parameters",
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
    /// - Returns: A Result containing either the modified URLRequest or a SUNetworkError.
    private func encodeJSONParameters(request: inout URLRequest, parameters: Encodable?) -> Result<URLRequest, SUNetworkError> {
        guard let parameters = parameters else { return .success(request) }
        do {
            let jsonData = try JSONEncoder().encode(parameters)
            request.httpBody = jsonData
            return .success(request)
        } catch {
            return .failure(.serializationError(SUErrorContext(
                message: "Failed to encode JSON parameters",
                underlyingError: error
            )))
        }
    }
    
    /// Builds final headers by merging default and request headers, then applying interceptors.
    ///
    /// - Parameters:
    ///   - requestable: The SUURLRequestable object.
    ///   - encoding: The encoding type for the request.
    /// - Returns: Result with final headers dictionary or error.
    private func buildHeaders(for requestable: SUURLRequestable, encoding: SUNetworkEncoding) async -> Result<[String: String], SUNetworkError> {
        let defaultHeaders = headerProvider?.defaultHeaders() ?? [:]
        var headers = headerMerger.merge(defaultHeaders: defaultHeaders, requestHeaders: requestable.headers)
        
        // Apply interceptors with error handling
        for interceptor in headerInterceptors {
            do {
                headers = try await interceptor.intercept(headers: headers)
            } catch {
                let interceptorName = String(describing: type(of: interceptor))
                if interceptor.isCritical {
                    return .failure(.serializationError(SUErrorContext(
                        message: "Critical header interceptor '\(interceptorName)' failed",
                        underlyingError: error
                    )))
                }
                print("⚠️ Warning: Header interceptor '\(interceptorName)' failed: \(error.localizedDescription)")
            }
        }
        
        // Set Content-Type based on encoding (override if needed)
        switch encoding {
        case .json:
            setHeaderCaseInsensitiveInDict(&headers, key: "Content-Type", value: "application/json", onlyIfMissing: false)
        case .url:
            setHeaderCaseInsensitiveInDict(&headers, key: "Content-Type", value: "application/x-www-form-urlencoded", onlyIfMissing: false)
        }
        
        // Validate headers
        if validateHeaders {
            let validatedHeaders = SUHeaderValidator.validate(headers: headers)
            let invalidKeys = Set(headers.keys).subtracting(validatedHeaders.keys)
            if !invalidKeys.isEmpty {
                let invalidList = invalidKeys.map { "'\($0)': '\(headers[$0] ?? "")'" }.joined(separator: ", ")
                print("⚠️ Warning: Invalid headers removed: \(invalidList)")
            }
            headers = validatedHeaders
        }
        
        return .success(headers)
    }
    
    
    /// Sets header in dictionary with case-insensitive check.
    private func setHeaderCaseInsensitiveInDict(_ headers: inout [String: String], key: String, value: String, onlyIfMissing: Bool) {
        if onlyIfMissing {
            let exists = headers.keys.contains { $0.lowercased() == key.lowercased() }
            if exists { return }
        } else {
            if let existingKey = headers.keys.first(where: { $0.lowercased() == key.lowercased() }) {
                headers.removeValue(forKey: existingKey)
            }
        }
        headers[key] = value
    }
    
    /// Sets header in URLRequest with case-insensitive check.
    private func setHeaderCaseInsensitive(_ request: inout URLRequest, key: String, value: String, onlyIfMissing: Bool) {
        if onlyIfMissing {
            let exists = request.allHTTPHeaderFields?.keys.contains { $0.lowercased() == key.lowercased() } ?? false
            if exists { return }
        }
        request.setValue(value, forHTTPHeaderField: key)
    }
}

