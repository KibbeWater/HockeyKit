//
//  StandingService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Foundation

class StandingService: StandingServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    private let configuration: EndpointConfiguration

    init(networkManager: NetworkManagerProtocol, configuration: EndpointConfiguration = .default) {
        self.networkManager = networkManager
        self.configuration = configuration
    }
    
    func getStandings(ssgtUuid: String) async throws -> Standings {
        do {
            // Try new v2 API first
            let standings: Standings = try await networkManager.request(
                endpoint: Endpoint.standingsV2(ssgtUuid),
                configuration: configuration
            )
            return standings
        } catch let error as HockeyAPIError {
            // Only fallback on network/HTTP errors, not decoding errors
            switch error {
            case .networkError, .serverError:
                // Try old API as fallback
                let standings: Standings = try await networkManager.request(
                    endpoint: Endpoint.standings(ssgtUuid),
                    configuration: configuration
                )
                return standings
            default:
                // Decoding errors or other errors should not trigger fallback
                throw error
            }
        }
    }
}
