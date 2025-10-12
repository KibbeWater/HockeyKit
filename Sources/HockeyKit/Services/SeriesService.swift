//
//  SeriesService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Foundation

fileprivate struct SeasonAPIResponse: Codable {
    let season: [Season]
    let series: [Series]
    
    let ssgtUuid: String
    
    struct Series: Codable {
        let uuid: String
    }
}

class SeriesService: SeriesServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    private func getSiteSettings() async throws -> SeasonAPIResponse {
        let res: SeasonAPIResponse = try await networkManager.request(endpoint: Endpoint.siteSettings)
        return res
    }
    
    func getCurrentSeries() async throws -> Series? {
        guard let uuid = try await getSiteSettings().series.first?.uuid else { return nil }
        return Series(id: uuid)
    }
}
