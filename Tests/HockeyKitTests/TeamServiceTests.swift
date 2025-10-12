//
//  TeamServiceTests.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Testing
@testable import HockeyKit

@Suite("Service - Season Service")
struct TeamServiceTests {
    let mockNetworkManager = MockNetworkManager()
    let networkManager: NetworkManagerProtocol = NetworkManager.create()
    
    let mockTeamService: TeamService
    let teamService: TeamService
    
    init() {
        self.mockTeamService = TeamService(networkManager: mockNetworkManager)
        self.teamService = TeamService(networkManager: networkManager)
    }
    
    @Test("Get Teams - Request Success")
    func getTeamsRequestSuccess() async throws {
        let request = try await teamService.getTeams()
        #expect(request.isEmpty == false)
    }
    
    @Test("Get Team - Request Success")
    func getTeamRequestSuccess() async throws {
        let _ = try await teamService.getTeam(withId: "3db0-3db09jXTE")
    }
    
    @Test("Get Lineup - Request Success")
    func getLineupRequestSuccess() async throws {
        guard let team = try? await teamService.getTeams().first else {
            Issue.record("No team found")
            return
        }
        let res = try await teamService.getLineup(team: team)
        #expect(res.isEmpty == false)
    }
}
