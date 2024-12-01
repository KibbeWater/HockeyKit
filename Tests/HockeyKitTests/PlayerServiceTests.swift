//
//  PlayerServiceTests.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Testing
@testable import HockeyKit

@Suite("Service - Player Service")
struct PlayerServiceTests {
    let mockNetworkManager = MockNetworkManager()
    let networkManager: NetworkManager = NetworkManager()
    
    let mockPlayerService: PlayerService
    let playerService: PlayerService
    
    let mockPlayerId = "qQ9-8fcc4epep" // Joel Lassinanti
    
    init() {
        self.mockPlayerService = PlayerService(networkManager: mockNetworkManager)
        self.playerService = PlayerService(networkManager: networkManager)
    }
    
    @Test("Get Player - Request Success")
    func getPlayerRequestSuccess() async throws {
        let _ = try await playerService.getPlayer(withId: mockPlayerId)
    }
    
    @Test("Get Player Logs - Request Success")
    func getPlayerLogsRequestSuccess() async throws {
        guard let player = try? await playerService.getPlayer(withId: mockPlayerId) else {
            Issue.record("Player not found")
            return
        }
        let _ = try await playerService.getGameLog(player)
    }
}
