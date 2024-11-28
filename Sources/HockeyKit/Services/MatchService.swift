//
//  MatchService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation
import Cache

class MatchService: MatchServiceProtocol {
    private let networkManager: NetworkManager
    private let cache = initCache(forKey: "MatchService")
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getLatest() async throws -> [Game] {
        return try await networkManager.request(endpoint: .matchesLatest)
    }
    
    func getSeasonSchedule(_ season: Season) async throws -> [Game] {
        let scheduleStorage = cache.transformCodable(ofType: [Game].self)
        
        if let cachedSchedule = try? await scheduleStorage.async.object(forKey: season.uuid) {
            return cachedSchedule
        }
        
        let games: [Game] = try await networkManager.request(endpoint: .matchesSchedule(season, .regular))
        
        try? await scheduleStorage.async.setObject(games, forKey: season.uuid, expiry: .seconds(24 * 60 * 60))
        
        return games
    }
}
