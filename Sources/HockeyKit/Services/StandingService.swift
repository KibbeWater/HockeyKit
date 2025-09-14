//
//  StandingService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

class StandingService: StandingServiceProtocol {
    private let networkManager: NetworkManager
    private let cache = initCache(forKey: "StandingService")
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func resetCache() {
        try? cache.removeAll()
    }
    
    func getStandings(ssgtUuid: String) async throws -> Standings {
        let standingsStorage = cache.transformCodable(ofType: Standings.self)
        
        if let standings = try? await standingsStorage.async.object(forKey: "standings-list") {
            return standings
        }
        
        let standings: Standings = try await networkManager.request(endpoint: Endpoint.standings(ssgtUuid))
        
        try? await standingsStorage.async.setObject(standings, forKey: "standings-list")
        return standings
    }
}
