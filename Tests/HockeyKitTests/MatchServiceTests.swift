//
//  MatchServiceTests.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation
import Testing
@testable import HockeyKit

@Suite("Service - Match Service")
struct MatchServiceTests {
    @Test("Get Latest - Request Succeeds")
    func getLatestRequestSucceeds() async throws {
        let networkManager = NetworkManager()
        let matchService = MatchService(networkManager: networkManager)
        
        let request = try await matchService.getLatest()
        #expect(request.isEmpty == false)
    }
    
    @Test("Get Season Schedule - Request Succeeds")
    func getSeasonScheduleRequestSucceeds() async throws {
        let networkManager = NetworkManager()
        let matchService = MatchService(networkManager: networkManager)
        let seasonService = SeasonService(networkManager: networkManager)
        
        guard let season = try? await seasonService.getCurrent() else {
            Issue.record("Could not get current season")
            return
        }
        
        let request = try await matchService.getSeasonSchedule(season)
        #expect(request.isEmpty == false)
    }
}
