//
//  SUNetworkService.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation

// MARK: - NetworkService

/// Main service for executing network requests.
open class SUNetworkService {
    private let urlRequestFactory: URLRequestBuilding
    private let sessionConfigurator: SessionConfigurable
    private let responseDecoder: ResponseDecoder
    private let session: URLSession

    /// Initializes a new NetworkService instance.
    ///
    /// - Parameters:
    ///   - sessionConfigurator: The configurator for URLSessions.
    ///   - responseDecoder: The decoder for network responses.
    public init(
        sessionConfigurator: SessionConfigurable = SessionConfigurator(),
        responseDecoder: ResponseDecoder = JSONResponseDecoder()
    ) {
        self.urlRequestFactory = URLRequestBuilder()
        self.sessionConfigurator = sessionConfigurator
        self.responseDecoder = responseDecoder
        self.session = URLSession(configuration: sessionConfigurator.createConfiguration())
    }
}

// MARK: - NetworkServicing Implementation

extension SUNetworkService: SUNetworkServicing {
    /// Executes a network request and returns a decoded response.
    ///
    /// - Parameter request: The URLRequestable object.
    /// - Returns: A Result containing either the decoded response or a NetworkError.
    public func execute<T: Decodable>(_ request: URLRequestable) async -> Result<T, NetworkError> {
        var retries = 0
        while true {
            let result: Result<T, NetworkError> = await performRequest(request)
            switch result {
            case .success(let value):
                return .success(value)
            case .failure(let error):
                if retries >= request.retryConfig.maxRetries || !request.retryConfig.shouldRetry(error) {
                    return .failure(error)
                }
                retries += 1
                try? await Task.sleep(nanoseconds: UInt64(request.retryConfig.retryDelay * 1_000_000_000))
            }
        }
    }
}

// MARK: - Perform Request

extension SUNetworkService {
    /// Performs a single network request attempt.
    ///
    /// - Parameter request: The URLRequestable object.
    /// - Returns: A Result containing either the decoded response or a NetworkError.
    private func performRequest<T: Decodable>(_ request: URLRequestable) async -> Result<T, NetworkError> {
        let urlRequestResult = urlRequestFactory.createRequest(from: request)
        
        switch urlRequestResult {
        case .success(let urlRequest):
            do {
                let (data, response) = try await session.data(for: urlRequest)
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.invalidResponse(ErrorContext(
                        userMessage: "Invalid server response",
                        statusCode: nil,
                        errorDescription: "The server response was not an HTTP response"
                    )))
                }
                
                return handleResponse(data: data, httpResponse: httpResponse)
            } catch {
                return .failure(.networkFailed(error))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Handles the response from a network request.
    ///
    /// - Parameters:
    ///   - data: The response data.
    ///   - httpResponse: The HTTP response.
    /// - Returns: A Result containing either the decoded response or a NetworkError.
    private func handleResponse<T: Decodable>(data: Data, httpResponse: HTTPURLResponse) -> Result<T, NetworkError> {
        switch httpResponse.statusCode {
        case 200...299:
            return responseDecoder.decode(data)
        case 400...499:
            return .failure(.clientError(ErrorContext(
                userMessage: "Request failed",
                statusCode: httpResponse.statusCode,
                errorDescription: "The server returned a client error"
            )))
        case 500...599:
            return .failure(.serverError(ErrorContext(
                userMessage: "Server error occurred",
                statusCode: httpResponse.statusCode,
                errorDescription: "The server returned a server error"
            )))
        default:
            return .failure(.unexpectedError(ErrorContext(
                userMessage: "An unexpected error occurred",
                statusCode: httpResponse.statusCode,
                errorDescription: "Received an unexpected status code"
            )))
        }
    }
}
