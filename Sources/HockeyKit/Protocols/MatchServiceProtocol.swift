//
//  MatchServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

public protocol MatchServiceProtocol {
    func getLatest() async throws -> [Game]
    func getSeasonSchedule(_ season: Season) async throws -> [Game]
    
    func getMatchStats(_ game: Game) async throws -> GameStats
}
