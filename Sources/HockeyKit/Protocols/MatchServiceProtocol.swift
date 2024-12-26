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
    
    /// Retreive game information about live games
    ///
    /// > Warning: This function is unable to check if a game is live or not,
    /// > checks needs to be done by the developer where needed to ensure
    /// > the function won't error
    ///
    /// - Parameters:
    ///     - matchId: A live or already played game.
    ///
    /// - Returns: Information about a live game.
    func getMatch(_ matchId: String) async throws -> GameData
    
    func getMatchStats(_ game: Game) async throws -> GameStats
    func getMatchExtra(_ game: Game) async throws -> GameExtra
    func getMatchPBP(_ game: Game) async throws -> PBPEvents
}
