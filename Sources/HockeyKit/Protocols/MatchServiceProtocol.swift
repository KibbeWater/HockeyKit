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
    func getSeasonSchedule(_ season: Season, withTeams: [String]) async throws -> [Game]
    
    func getMatch(_ matchId: String) async throws -> GameData
    func getMatchStats(_ game: Game) async throws -> GameStats
    func getMatchExtra(_ game: Game) async throws -> GameExtra
    func getMatchPBP(_ game: Game) async throws -> PBPEvents
}
