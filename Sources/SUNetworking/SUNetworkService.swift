//
//  SUNetworkService.swift
//  SUNetworking
//
//  Created by Sinan Ulusoy on 29.07.2024.
//

import Foundation
import Combine

// MARK: - SUNetworkService

/// Main service for executing network requests.
open class SUNetworkService {
    private let urlRequestFactory: SUURLRequestBuilding
    private let sessionConfigurator: SUSessionConfigurable
    private let responseDecoder: SUResponseDecoder
    private let session: URLSession

    /// Initializes a new NetworkService instance.
    ///
    /// - Parameters:
    ///   - sessionConfigurator: The configurator for URLSessions.
    ///   - responseDecoder: The decoder for network responses.
    public init(
        sessionConfigurator: SUSessionConfigurable = SUSessionConfigurator(),
        responseDecoder: SUResponseDecoder = SUJSONResponseDecoder()
    ) {
        self.urlRequestFactory = SUURLRequestBuilder()
        self.sessionConfigurator = sessionConfigurator
        self.responseDecoder = responseDecoder
        self.session = URLSession(configuration: sessionConfigurator.createConfiguration())
    }
}

// MARK: - SUNetworkServicing Implementation

extension SUNetworkService: SUNetworkServicing {
    public func execute<T: Decodable>(_ request: SUURLRequestable) async -> Result<T, SUNetworkError> {
        await retryOperation(request: request) {
            await self.performRequest(request)
        }
    }

    public func execute<T: Decodable>(_ request: SUURLRequestable) -> AnyPublisher<T, SUNetworkError> {
        Deferred {
            Future { promise in
                Task {
                    let result: Result<T, SUNetworkError> = await self.execute(request)
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Perform Request

extension SUNetworkService {
    /// Performs a single network request attempt.
    ///
    /// - Parameter request: The SUURLRequestable object.
    /// - Returns: A Result containing either the decoded response or a SUNetworkError.
    private func performRequest<T: Decodable>(_ request: SUURLRequestable) async -> Result<T, SUNetworkError> {
        let urlRequestResult = urlRequestFactory.createRequest(from: request)
        
        switch urlRequestResult {
        case .success(let urlRequest):
            do {
                let (data, response) = try await session.data(for: urlRequest)
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.invalidResponse(SUErrorContext(
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
    /// - Returns: A Result containing either the decoded response or a SUNetworkError.
    private func handleResponse<T: Decodable>(data: Data, httpResponse: HTTPURLResponse) -> Result<T, SUNetworkError> {
        switch httpResponse.statusCode {
        case 200...299:
            return responseDecoder.decode(data)
        case 400...499:
            return .failure(.clientError(SUErrorContext(
                userMessage: "Request failed",
                statusCode: httpResponse.statusCode,
                errorDescription: "The server returned a client error"
            )))
        case 500...599:
            return .failure(.serverError(SUErrorContext(
                userMessage: "Server error occurred",
                statusCode: httpResponse.statusCode,
                errorDescription: "The server returned a server error"
            )))
        default:
            return .failure(.unexpectedError(SUErrorContext(
                userMessage: "An unexpected error occurred",
                statusCode: httpResponse.statusCode,
                errorDescription: "Received an unexpected status code"
            )))
        }
    }
}
