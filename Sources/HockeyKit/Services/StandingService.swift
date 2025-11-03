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
        let standings: Standings = try await networkManager.request(endpoint: Endpoint.standings(ssgtUuid), configuration: configuration)
        return standings
    }
}
