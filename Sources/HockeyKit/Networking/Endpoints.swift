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
    
    case player(String)
    case playerGameLog(Player)
    
    case standings(Series)
    
    case siteSettings

    var url: URL {
        switch self {
        case .matchesLatest: return Self.baseURL.appendingPathComponent("/gameday/gameheader")
        case .matchesSchedule(let season, let gameType, let team):
          return Self.baseURL.appendingPathComponent(
            "/sports/game-info"
          ).appending(queryItems: [
            .init(name: "seasonUuid", value: season.uuid),
            .init(name: "seriesUuid", value: "qQ9-bb0bzEWUk"),
            .init(name: "gameTypeUuid", value: gameType.rawValue),
            .init(name: "gamePlace", value: "all"),
            .init(name: "played", value: "all"),
          ]).appending(queryItems: team == nil ? [] : [
            .init(name: "teams[]", value: team!.name)
          ])
        case .matchExtra(let game): return Self.baseURL.appendingPathComponent("/sports/game-info/\(game.id)")
        case .match(let id): return Self.baseURL.appendingPathComponent("/gameday/game-overview/\(id)")
            
        case .teams: return Self.baseURL.appendingPathComponent("/site/settings")
        case .teamLineup(let team): return Self.baseURL.appendingPathComponent("/sports/players/\(team.id)")
            
        case .standings(let series): return Self.baseURL.appendingPathComponent("/sports/league-standings")
                .appending(queryItems: [.init(name: "ssgtUuid", value: series.id)])
            
        case .player(let id): return Self.baseURL.appendingPathComponent("/sports/player/profile-page")
                .appending(queryItems: [.init(name: "playerUuid", value: id)])
        case .playerGameLog(let player): return Self.baseURL.appendingPathComponent("/sports/player/playerProfile_gameLog")
                .appending(queryItems: [.init(name: "playerUuid", value: player.uuid)])
            
        case .siteSettings: return Self.baseURL.appendingPathComponent("/sports/season-series-game-types-filter")
        }
    }
}
