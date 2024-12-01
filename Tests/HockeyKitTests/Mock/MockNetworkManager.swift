//
//  MockNetworkManager.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//


@testable import HockeyKit

class MockNetworkManager: NetworkManager {
    var invokedRequest = false
    var invokedEndpoint: Endpoints?
    var completionResult: Any?

    override func request<T: Decodable>(endpoint: Endpoints) async throws -> T {
        invokedRequest = true
        invokedEndpoint = endpoint
        if let result = completionResult as? T {
            return result
        } else {
            fatalError("MockNetworkManager: completionResult type mismatch")
        }
    }
}
