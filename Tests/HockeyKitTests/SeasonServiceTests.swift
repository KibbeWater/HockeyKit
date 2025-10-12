//
//  SeasonService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Testing
@testable import HockeyKit

@Suite("Service - Season Service")
struct SeasonServiceTests {
    let mockNetworkManager = MockNetworkManager()
    let networkManager: NetworkManagerProtocol = NetworkManager.create()
    
    let mockSeasonService: SeasonService
    let seasonService: SeasonService
    
    init() {
        self.mockSeasonService = SeasonService(networkManager: mockNetworkManager)
        self.seasonService = SeasonService(networkManager: networkManager)
    }
    
    @Test("Get Seasons - Request Success")
    func getSeasonsRequestSuccess() async throws {
        let request = try await seasonService.getSeasons()
        #expect(request.isEmpty == false)
    }
    
    @Test("Get Current Season - Request Success")
    func getCurrentSeasonRequestSuccess() async throws {
        let _ = try await seasonService.getCurrent()
    }
}
