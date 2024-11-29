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
    let mockNetworkManager = MockNetworkManager()
    let networkManager: NetworkManager = NetworkManager()
    
    let mockMatchService: MatchService
    let matchService: MatchService
    
    let mockPlayerId = "qQ9-8fcc4epep" // Joel Lassinanti
    
    init() {
        self.mockMatchService = MatchService(networkManager: mockNetworkManager)
        self.matchService = MatchService(networkManager: networkManager)
    }
    
    @Test("Get Latest - Request Succeeds")
    func getLatestRequestSucceeds() async throws {
        let request = try await matchService.getLatest()
        #expect(request.isEmpty == false)
    }
    
    @Test("Get Season Schedule - Request Succeeds")
    func getSeasonScheduleRequestSucceeds() async throws {
        let seasonService = SeasonService(networkManager: networkManager)
        
        guard let season = try? await seasonService.getCurrent() else {
            Issue.record("Could not get current season")
            return
        }
        
        let request = try await matchService.getSeasonSchedule(season)
        #expect(request.isEmpty == false)
    }
    
    @Test("Get Match Stats - Request Succeeds")
    func getMatchStatsRequestSucceeds() async throws {
        guard let game = try? await matchService.getLatest().filter({$0.played}).first else {
            Issue.record("Could not get latest matches")
            return
        }
        
        let _ = try await matchService.getMatchStats(game)
    }
    
    @Test("Get Match Stats - Unplayed Game")
    func getMatchStatsUnplayedGame() async throws {
        guard let game = try? await matchService.getLatest().filter({ !$0.played }).first else {
            Issue.record("Could not find unplayed game")
            return
        }
        
        await #expect {
            let _ = try await matchService.getMatchStats(game)
        } throws: { (error) async -> Bool in
            guard let apiErr = error as? HockeyAPIError else {
                Issue.record("Error is not an API error")
                return false
            }
            
            guard apiErr == .gameNotPlayed else {
                Issue.record("Error is not a game not played error")
                return false
            }
            return true
        }
    }
}
