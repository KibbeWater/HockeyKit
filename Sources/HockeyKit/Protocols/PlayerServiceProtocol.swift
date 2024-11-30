//
//  PlayerServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

public protocol PlayerServiceProtocol {
    func getPlayer(withId: String) async throws -> Player
    func getGameLog(_ player: Player) async throws -> [PlayerGameLog]
}
