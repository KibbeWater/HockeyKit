//
//  StandingServiceTests.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Testing
@testable import HockeyKit

@Suite("Service - Standing Service")
struct StandingServiceTests {
    let mockNetworkManager = MockNetworkManager()
    let networkManager: NetworkManager = NetworkManager()
    
    let mockStandingService: StandingService
    let standingService: StandingService
    
    init() {
        self.mockStandingService = StandingService(networkManager: mockNetworkManager)
        self.standingService = StandingService(networkManager: networkManager)
    }
    
    @Test("Get Standings - Request Success")
    func getCurSeriesRequestSuccess() async throws {
        let seasonService = SeasonService(networkManager: networkManager)
        
        guard let ssgtUuid = try? await seasonService.getCurrentSsgt() else {
            Issue.record("Unable to find current ssgt")
            return
        }
        
        let _ = try await standingService.getStandings(ssgtUuid: ssgtUuid)
    }
}
