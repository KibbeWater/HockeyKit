//
//  MockNetworkManager.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//


@testable import HockeyKit

final class MockNetworkManager: NetworkManagerProtocol, @unchecked Sendable {
    var invokedRequest = false
    var invokedEndpoint: Endpoints?
    var completionResult: Any?

    func request<T: Decodable>(endpoint: Endpoints, configuration: EndpointConfiguration) async throws -> T {
        invokedRequest = true
        invokedEndpoint = endpoint
        if let result = completionResult as? T {
            return result
        } else {
            fatalError("MockNetworkManager: completionResult type mismatch")
        }
    }
}
