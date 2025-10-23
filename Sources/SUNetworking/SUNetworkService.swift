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
    ///   - headerConfiguration: Configuration for header management.
    public init(
        sessionConfigurator: SUSessionConfigurable = SUSessionConfigurator(),
        responseDecoder: SUResponseDecoder = SUJSONResponseDecoder(),
        headerConfiguration: SUHeaderConfiguration = .default
    ) {
        self.urlRequestFactory = SUURLRequestBuilder(
            headerMerger: SUHeaderMerger(strategy: headerConfiguration.mergeStrategy),
            headerInterceptors: headerConfiguration.interceptors,
            headerProvider: headerConfiguration.provider,
            validateHeaders: headerConfiguration.validateHeaders
        )
        self.sessionConfigurator = sessionConfigurator
        self.responseDecoder = responseDecoder
        self.session = URLSession(configuration: sessionConfigurator.createConfiguration())
    }
    
    /// Convenience initializer with header interceptors.
    ///
    /// - Parameters:
    ///   - sessionConfigurator: The configurator for URLSessions.
    ///   - responseDecoder: The decoder for network responses.
    ///   - headerInterceptors: Array of header interceptors for dynamic header modification.
    public convenience init(
        sessionConfigurator: SUSessionConfigurable = SUSessionConfigurator(),
        responseDecoder: SUResponseDecoder = SUJSONResponseDecoder(),
        headerInterceptors: [SUHeaderInterceptor]
    ) {
        let configuration = SUHeaderConfiguration(
            interceptors: headerInterceptors
        )
        self.init(
            sessionConfigurator: sessionConfigurator,
            responseDecoder: responseDecoder,
            headerConfiguration: configuration
        )
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
        let urlRequestResult = await urlRequestFactory.createRequest(from: request)
        
        switch urlRequestResult {
        case .success(let urlRequest):
            do {
                let (data, response) = try await session.data(for: urlRequest)
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.invalidResponse(SUErrorContext(message: "Invalid HTTP response")))
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
                message: "Client error",
                statusCode: httpResponse.statusCode
            )))
        case 500...599:
            return .failure(.serverError(SUErrorContext(
                message: "Server error",
                statusCode: httpResponse.statusCode
            )))
        default:
            return .failure(.unexpectedError(SUErrorContext(
                message: "Unexpected status code",
                statusCode: httpResponse.statusCode
            )))
        }
    }
}
