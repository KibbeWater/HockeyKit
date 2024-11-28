//
//  MockNetworkManager.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//


@testable import HockeyKit

class MockNetworkManager: NetworkManager {
    var invokedRequest = false
    var invokedEndpoint: Endpoint?
    var completionResult: Any?

    override func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, any Error>) -> Void) {
        invokedRequest = true
        invokedEndpoint = endpoint
        if let result = completionResult as? Result<T, any Error> {
            completion(result)
        } else {
            fatalError("MockNetworkManager: completionResult type mismatch")
        }
    }
}
