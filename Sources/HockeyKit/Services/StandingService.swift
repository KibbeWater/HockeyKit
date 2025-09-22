//
//  StandingService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Foundation

class StandingService: StandingServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getStandings(ssgtUuid: String) async throws -> Standings {
        let standings: Standings = try await networkManager.request(endpoint: Endpoint.standings(ssgtUuid))
        return standings
    }
}
