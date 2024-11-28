//
//  Endpoints.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

enum Endpoint {
    static let baseURL = URL(string: "https://shl.se/api")!

    case matchesLatest
    case matchesSchedule(Season, GameType = GameType.regular, Team? = nil)
    case matchExtra(Game)
    case match(String)
    
    case teams
    case teamLineup(SiteTeam)
    
    case seasons

    var url: URL {
        switch self {
        case .matchesLatest: return Self.baseURL.appendingPathComponent("/gameday/gameheader")
        case .matchesSchedule(let season, let gameType, let team): return Self.baseURL.appendingPathComponent("/sports/game-info?seasonUuid=\(season.uuid)&seriesUuid=qQ9-bb0bzEWUk&gameTypeUuid=\(gameType.rawValue)\(team == nil ? "" : "&teams[]=\(team!)")&gamePlace=all&played=all")
        case .matchExtra(let game): return Self.baseURL.appendingPathComponent("/sports/game-info/\(game.id)")
        case .match(let id): return Self.baseURL.appendingPathComponent("/gameday/game-overview/\(id)")
            
        case .teams: return Self.baseURL.appendingPathComponent("/site/settings")
        case .teamLineup(let team): return Self.baseURL.appendingPathComponent("/sports/players/\(team.id)")
            
        case .seasons: return Self.baseURL.appendingPathComponent("/sports/season-series-game-types-filter")
        }
    }
}
