//
//  SeasonService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

fileprivate struct SeasonAPIResponse: Codable {
    let season: [Season]
    let ssgtUuid: String
}

class SeasonService: SeasonServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    private func getSiteSettings() async throws -> SeasonAPIResponse {
        let res: SeasonAPIResponse = try await networkManager.request(endpoint: Endpoint.siteSettings)
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
