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
    private let configuration: EndpointConfiguration

    init(networkManager: NetworkManagerProtocol, configuration: EndpointConfiguration = .default) {
        self.networkManager = networkManager
        self.configuration = configuration
    }
    
    private func getSiteSettings() async throws -> SeasonAPIResponse {
        let res: SeasonAPIResponse = try await networkManager.request(endpoint: Endpoint.siteSettings, configuration: configuration)
        return res
    }
    
    func getCurrentSeries() async throws -> Series? {
        guard let uuid = try await getSiteSettings().series.first?.uuid else { return nil }
        return Series(id: uuid)
    }
}
