//
//  NetworkManager.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// URLSession-based network manager for iOS/macOS platforms
final class URLSessionNetworkManager: NetworkManagerProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(endpoint: Endpoints) async throws -> T {
        let request = URLRequest(url: endpoint.url)
        // request.httpMethod = endpoint.method

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw HockeyAPIError.networkError
        }

        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch(let err) {
            print(err)
            throw HockeyAPIError.decodingError
        }
    }
}

/// Platform-conditional factory for creating the appropriate NetworkManager
enum NetworkManager {
    static func create() -> NetworkManagerProtocol {
        #if os(Linux)
        return AsyncHTTPNetworkManager()
        #else
        return URLSessionNetworkManager()
        #endif
    }
}
