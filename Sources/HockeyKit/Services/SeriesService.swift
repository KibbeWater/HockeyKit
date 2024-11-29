//
//  SeriesService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

fileprivate struct SeasonAPIResponse: Codable {
    let season: [Season]
    let ssgtUuid: String
}

class SeriesService: SeriesServiceProtocol {
    private let networkManager: NetworkManager
    private let cache = initCache(forKey: "SeriesService")
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
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
    
    func getCurrentSeries() async throws -> Series? {
        return Series(id: try await getSiteSettings().ssgtUuid)
    }
}
