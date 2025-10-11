//
//  Endpoints.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

protocol Endpoints {
    static var baseURL: URL { get }

    var url: URL { get }
}

enum Endpoint: Endpoints {
    static let baseURL = URL(string: "https://www.shl.se/api")!

    case matchesLatest
    case matchesSchedule(Season, Series, GameType = GameType.regular, [String]? = nil)
    case matchStats(Game)
    case matchExtra(Game)
    case match(String)

    case teams
    case teamLineup(SiteTeam)

    case player(String)
    case playerGameLog(Player)

    case standings(String)

    case siteSettings

    var url: URL {
        switch self {
        case .matchesLatest: return Self.baseURL.appendingPathComponent("/gameday/gameheader")
        case .matchesSchedule(let season, let series, let gameType, let teams):
            return Self.baseURL.appendingPathComponent(
                "/sports-v2/game-schedule"
            ).appending(queryItems: [
                .init(name: "seasonUuid", value: season.uuid),
                .init(name: "seriesUuid", value: series.id),
                .init(name: "gameTypeUuid", value: gameType.rawValue),
                .init(name: "gamePlace", value: "all"),
                .init(name: "played", value: "all"),
            ]).appending(
                queryItems: teams == nil
                    ? []
                    : [
                        .init(name: "teams[]", value: teams!.joined(separator: ","))
                    ])
        case .matchStats(let game):
            return Self.baseURL.appendingPathComponent("/gameday/team-stats/\(game.id)")
        case .matchExtra(let game):
            return Self.baseURL.appendingPathComponent("/sports-v2/game-info/\(game.id)")
        case .match(let id):
            return Self.baseURL.appendingPathComponent("/sports-v2/game-info/\(id)")

        case .teams: return Self.baseURL.appendingPathComponent("/site/settings")
        case .teamLineup(let team):
            return Self.baseURL.appendingPathComponent("/sports/players/\(team.id)")

        case .standings(let ssgtUuid):
            return Self.baseURL.appendingPathComponent("/sports/league-standings")
                .appending(queryItems: [.init(name: "ssgtUuid", value: ssgtUuid)])

        case .player(let id):
            return Self.baseURL.appendingPathComponent("/sports/player/profile-page")
                .appending(queryItems: [.init(name: "playerUuid", value: id)])
        case .playerGameLog(let player):
            return Self.baseURL.appendingPathComponent(
                "/statistics-v2/athlete/playerProfile_gameLog"
            )
            .appending(queryItems: [.init(name: "playerUuid", value: player.uuid)])

        case .siteSettings:
            return Self.baseURL.appendingPathComponent("/sports/season-series-game-types-filter")
        }
    }
}

enum LiveEndpoint: Endpoints {
    static let baseURL = URL(string: "https://game-data.s8y.se")!

    case playByPlay(Game)

    var url: URL {
        switch self {
        case .playByPlay(let game):
            return Self.baseURL.appendingPathComponent("/play-by-play/by-game-uuid/\(game.id)")
        }
    }
}

enum BroadcasterEndpoint: Endpoints {
    static let baseURL: URL = URL(string: "https://game-broadcaster.s8y.se")!

    case live

    var url: URL {
        switch self {
        case .live: return Self.baseURL.appendingPathComponent("/live/game")
        }
    }
}
