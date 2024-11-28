//
//  SeasonService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation
import Cache

fileprivate struct SeasonAPIResponse: Decodable {
    let season: [Season]
}

class SeasonService: SeasonServiceProtocol {
    private let networkManager: NetworkManager
    private let cache = initCache(forKey: "SeasonService")
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getSeasons() async throws -> [Season] {
        let seasonStorage = cache.transformCodable(ofType: [Season].self)
        
        if let cachedSeasons = try? await seasonStorage.async.object(forKey: "season-list") {
            return cachedSeasons
        }
        
        let res: SeasonAPIResponse = try await networkManager.request(endpoint: .seasons)
        
        try? await seasonStorage.async.setObject(res.season, forKey: "season-list", expiry: .seconds(24 * 60 * 60))
        
        return res.season
    }
    
    func getCurrent() async throws -> Season {
        let seasons = try await getSeasons()
        guard let firstSeason = seasons.first else {
            throw HockeyAPIError.internalError(description: "Season response was empty")
        }
        return firstSeason
    }
}
