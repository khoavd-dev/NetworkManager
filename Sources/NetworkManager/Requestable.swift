//
//  Requestable.swift
//  NetworkManager
//
//  Created by Khoa Vo on 5/5/25.
//

import Foundation

// MARK: - Requestable
public protocol Requestable: NetworkConfiguration {
    associatedtype Response
    var urlPath: String { get }
    var httpMethod: HTTPMethod { get }
    var requestBody: Codable? { get }
    var queryParameters: [String: String]? { get }
    var headers: [String: String]? { get }
    
    func request(using session: URLSession, maxRetries: Int, retryDelay: TimeInterval) async throws -> Response
}

// Default Values
public extension Requestable {
    var requestBody: Codable? { nil }
    var queryParameters: [String: String]? { nil }
    var headers: [String: String]? { nil }
}

// Public Functions
public extension Requestable {
    func request<Response: Decodable>(using session: URLSession = .shared, maxRetries: Int = 3, retryDelay: TimeInterval = 1.0) async throws -> Response {
        guard let urlRequest = try buildURLRequest() else {
            throw NetworkError.invalidURL
        }
        
        var attempt = 0
        var lastError: Error?
        
        while attempt <= maxRetries {
            do {
                try Task.checkCancellation()
                let (data, response) = try await session.data(for: urlRequest)
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                guard (200..<300).contains(statusCode) else {
                    throw NetworkError.httpError(code: statusCode, data: data)
                }
                
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                    throw NetworkError.noInternetConnection
                }
                
                lastError = error
                attempt += 1
                if attempt > maxRetries {
                    break
                }

                try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
            }
        }
        
        throw lastError ?? NetworkError.dataTaskFailed
    }
}

// Private Functions
extension Requestable {
    private func buildURLRequest() throws -> URLRequest? {
        guard let baseURL = Self.baseURL, var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }

        if let apiVersion = Self.apiVersion {
            components.path += "\(apiVersion)"
        }
        components.path += urlPath
        
        if let queryParameters {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let finalURL = components.url else { return nil }
        var urlRequest = URLRequest(url: finalURL)
        
        urlRequest.httpMethod = httpMethod.rawValue
        
        if let headers {
            headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        if let requestBody {
            urlRequest.httpBody = try JSONEncoder().encode(requestBody)
        }
        
        return urlRequest
    }
}
