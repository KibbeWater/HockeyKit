//
//  SeasonService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation
import Cache

fileprivate struct SeasonAPIResponse: Codable {
    let season: [Season]
    let ssgtUuid: String
}

class SeasonService: SeasonServiceProtocol {
    private let networkManager: NetworkManager
    private let cache = initCache(forKey: "SeasonService")
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getCache() -> Storage<String, String> {
        return cache
    }
    
    func resetCache() {
        try? cache.removeAll()
    }
    
    func resetCache(forKey: String) {
        try? cache.removeObject(forKey: forKey)
    }
    
    private func getSiteSettings() async throws -> SeasonAPIResponse {
        let seasonStorage = cache.transformCodable(ofType: SeasonAPIResponse.self)
        
        if let cachedSeasons = try? await seasonStorage.async.object(forKey: "season-response") {
            return cachedSeasons
        }
        
        let res: SeasonAPIResponse = try await networkManager.request(endpoint: Endpoint.siteSettings)
        
        try? await seasonStorage.async.setObject(res, forKey: "season-response", expiry: .seconds(24 * 60 * 60))
        
        return res
    }

    func getSeasons() async throws -> [Season] {
        return try await getSiteSettings().season
    }
    
    func getCurrent() async throws -> Season {
        let seasons = try await getSeasons()
        guard let firstSeason = seasons.first else {
            throw HockeyAPIError.internalError(description: "Season response was empty")
        }
        return firstSeason
    }
    
    func getCurrentSsgt() async throws -> String {
        return try await getSiteSettings().ssgtUuid
    }
}
