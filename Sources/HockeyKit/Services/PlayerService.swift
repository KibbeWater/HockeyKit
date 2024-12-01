//
//  PlayerService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

class PlayerService: PlayerServiceProtocol {
    private let networkManager: NetworkManager
    private let cache = initCache(forKey: "PlayerService")
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getPlayer(withId id: String) async throws -> Player {
        let playerStorage = cache.transformCodable(ofType: Player.self)
        
        if let player = try? await playerStorage.async.object(forKey: "p_" + id) {
            return player
        }
        
        let player: Player = try await networkManager.request(endpoint: Endpoint.player(id))
        try? await playerStorage.async.setObject(player, forKey: "p_" + id, expiry: .seconds(24 * 60 * 60))
        
        return player
    }
    
    func getGameLog(_ player: Player) async throws -> PlayerGameLog {
        let logStorage = cache.transformCodable(ofType: [LogResponse].self)
        
        if let logs = try? await logStorage.async.object(forKey: "log_\(player.uuid)") {
            guard let log = logs.flatMap({ $0.stats }).first else { throw HockeyAPIError.notFound }
            return log
        }
        
        let logs: [LogResponse] = try await networkManager.request(endpoint: Endpoint.playerGameLog(player))
        try? await logStorage.async.setObject(logs, forKey: "log_\(player.uuid)")
        
        guard let log = logs.flatMap({ $0.stats }).first else { throw HockeyAPIError.notFound }
        
        return log
    }
}

fileprivate struct LogResponse: Codable {
    public let stats: [PlayerGameLog]
}
