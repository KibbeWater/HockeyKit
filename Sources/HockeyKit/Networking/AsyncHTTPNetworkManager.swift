//
//  AsyncHTTPNetworkManager.swift
//  HockeyKit
//
//  SwiftNIO-based network manager for Linux server platforms
//

#if os(Linux)
import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1

/// AsyncHTTPClient-based network manager for Linux platforms
final class AsyncHTTPNetworkManager: NetworkManagerProtocol {
    private let httpClient: HTTPClient

    init() {
        self.httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
    }

    deinit {
        try? httpClient.syncShutdown()
    }

    func request<T: Decodable>(endpoint: Endpoints, configuration: EndpointConfiguration) async throws -> T {
        let url = endpoint.url(using: configuration).absoluteString

        // Create HTTP request
        var request = HTTPClientRequest(url: url)
        request.method = .GET
        request.headers.add(name: "Accept", value: "application/json")

        // Execute request
        let response = try await httpClient.execute(request, timeout: .seconds(30))

        // Check status code
        guard (200...299).contains(response.status.code) else {
            throw HockeyAPIError.networkError
        }

        // Collect response body
        let body = try await response.body.collect(upTo: 10 * 1024 * 1024) // 10MB max

        // Convert ByteBuffer to Data
        let data = Data(body.readableBytesView)

        // Decode JSON response
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch(let err) {
            print(err)
            throw HockeyAPIError.decodingError
        }
    }
}
#endif
