//
//  SeriesServiceTests.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Testing
@testable import HockeyKit

@Suite("Service - Series Service")
struct SeriesServiceTests {
    let mockNetworkManager = MockNetworkManager()
    let networkManager: NetworkManagerProtocol = NetworkManager.create()
    
    let mockSeriesService: SeriesService
    let seriesService: SeriesService
    
    init() {
        self.mockSeriesService = SeriesService(networkManager: mockNetworkManager)
        self.seriesService = SeriesService(networkManager: networkManager)
    }
    
    @Test("Get Current Series - Request Success")
    func getCurSeriesRequestSuccess() async throws {
        let _ = try await seriesService.getCurrentSeries()
    }
}
