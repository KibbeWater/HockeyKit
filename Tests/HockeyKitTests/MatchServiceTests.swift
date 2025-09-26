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
    let mockTeamId = "1a71-1a71gTHKh" // Luleå Hockey
    
    init() {
        self.mockMatchService = MatchService(networkManager: mockNetworkManager)
        self.matchService = MatchService(networkManager: networkManager)
    }
    
    @Test("Get Latest - Request Succeeds")
    func getLatestRequestSucceeds() async throws {
        let request = try await matchService.getLatest()
        #expect(request.isEmpty == false)
    }
    
    @Test("Get Match - Request Succeeds")
    func getMatchSucceeds() async throws {
        guard let latest = try? await matchService.getLatest(), let match = latest.first else {
            Issue.record("Could not get matches")
            return
        }
        
        let request = try await matchService.getMatch(match.id)
    }
    
    @Test("Get Season Schedule - Request Succeeds")
    func getSeasonScheduleRequestSucceeds() async throws {
        let seasonService = SeasonService(networkManager: networkManager)
        let seriesService = SeriesService(networkManager: networkManager)
        
        guard let season = try? await seasonService.getCurrent() else {
            Issue.record("Could not get current season")
            return
        }
        
        guard let series = try? await seriesService.getCurrentSeries() else {
            Issue.record("Could not get current season")
            return
        }
        
        let request = try await matchService.getSeasonSchedule(season, series: series)
        #expect(request.isEmpty == false)
    }
    
    @Test("Get Season Schedule - Team Filtering")
    func getSeasonScheduleTeamFiltering() async throws {
        let seasonService = SeasonService(networkManager: networkManager)
        let seriesService = SeriesService(networkManager: networkManager)
        let teamService = TeamService(networkManager: networkManager)
        
        guard let season = try? await seasonService.getCurrent() else {
            Issue.record("Could not get current season")
            return
        }
        
        guard let series = try? await seriesService.getCurrentSeries() else {
            Issue.record("Could not get current season")
            return
        }
        
        guard let team = try? await teamService.getTeam(withId: mockTeamId) else {
            Issue.record("Could not get team \(mockTeamId)")
            return
        }
        
        let request = try await matchService.getSeasonSchedule(season, series: series, withTeams: [mockTeamId])
        if request.isEmpty {
            Issue.record("No matches found for team \(mockTeamId)")
        }
        
        #expect(request.allSatisfy({ $0.homeTeam.code == team.teamNames.code || $0.awayTeam.code == team.teamNames.code }))
    }
    
    @Test("Get Season Schedule - Date Parsing")
    func getSeasonScheduleDateParsing() async throws {
        let seasonService = SeasonService(networkManager: networkManager)
        let seriesService = SeriesService(networkManager: networkManager)
        
        guard let season = try? await seasonService.getCurrent() else {
            Issue.record("Could not get current season")
            return
        }
        
        guard let series = try? await seriesService.getCurrentSeries() else {
            Issue.record("Could not get current season")
            return
        }
        
        let request = try await matchService.getSeasonSchedule(season, series: series)
        #expect(request.allSatisfy({ $0.date != Date.distantPast }))
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
    
    @Test("Get Match Extra - Request Succeeds")
    func getMatchExtraRequestSucceeds() async throws {
        guard let game = try? await matchService.getLatest().filter({$0.played}).first else {
            Issue.record("Could not get latest matches")
            return
        }
        
        let _ = try await matchService.getMatchExtra(game)
    }
    
    @Test("Get Match Extra - Unplayed Game")
    func getMatchExtraUnplayedGame() async throws {
        guard let game = try? await matchService.getLatest().filter({ !$0.played }).first else {
            Issue.record("Could not find unplayed game")
            return
        }
        
        await #expect {
            let _ = try await matchService.getMatchExtra(game)
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
    
    @Test("Get Match PBP - Request Succeeds")
    func getMatchPBPRequestSucceeds() async throws {
        guard let game = try? await matchService.getLatest().filter({$0.played}).first else {
            Issue.record("Could not get latest matches")
            return
        }
        
        let res = try await matchService.getMatchPBP(game)
        #expect(res.events.isEmpty == false)
    }
    
    @Test("Get Match PBP - Unplayed Game")
    func getMatchPBPUnplayedGame() async throws {
        guard let game = try? await matchService.getLatest().filter({ !$0.played }).first else {
            Issue.record("Could not find unplayed game")
            return
        }
        
        await #expect {
            let _ = try await matchService.getMatchPBP(game)
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
