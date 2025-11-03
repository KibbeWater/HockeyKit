//
//  NetworkManagerProtocol.swift
//  HockeyKit
//
//  Protocol for abstracting HTTP networking operations across different platforms
//

import Foundation

/// Protocol defining the interface for network operations
protocol NetworkManagerProtocol: Sendable {
    /// Performs an HTTP request and decodes the response
    /// - Parameters:
    ///   - endpoint: The endpoint to request
    ///   - configuration: The endpoint configuration containing base URLs
    /// - Returns: Decoded response of type T
    /// - Throws: HockeyAPIError if the request fails or decoding fails
    func request<T: Decodable>(endpoint: Endpoints, configuration: EndpointConfiguration) async throws -> T
}
