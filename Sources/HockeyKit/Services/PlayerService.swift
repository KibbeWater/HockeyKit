//
//  PlayerService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Foundation

class PlayerService: PlayerServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    private let configuration: EndpointConfiguration

    init(networkManager: NetworkManagerProtocol, configuration: EndpointConfiguration = .default) {
        self.networkManager = networkManager
        self.configuration = configuration
    }
    
    func getPlayer(withId id: String) async throws -> Player {
        let player: Player = try await networkManager.request(endpoint: Endpoint.player(id), configuration: configuration)
        return player
    }
    
    func getGameLog(_ player: Player) async throws -> [PlayerGameLog] {
        let logs: [LogResponse] = try await networkManager.request(endpoint: Endpoint.playerGameLog(player), configuration: configuration)
        
        return logs.flatMap({ $0.stats })
    }
}

fileprivate struct LogResponse: Codable {
    public let stats: [PlayerGameLog]
}
