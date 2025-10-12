//
//  StandingService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Foundation

class StandingService: StandingServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func getStandings(ssgtUuid: String) async throws -> Standings {
        let standings: Standings = try await networkManager.request(endpoint: Endpoint.standings(ssgtUuid))
        return standings
    }
}
