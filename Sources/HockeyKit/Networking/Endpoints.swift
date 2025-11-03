//
//  Endpoints.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

protocol Endpoints {
    func url(using configuration: EndpointConfiguration) -> URL
}

enum Endpoint: Endpoints {
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

    func url(using configuration: EndpointConfiguration) -> URL {
        let baseURL = configuration.baseURL
        switch self {
        case .matchesLatest: return baseURL.appendingPathComponent("/gameday/gameheader")
        case .matchesSchedule(let season, let series, let gameType, let teams):
            return baseURL.appendingPathComponent(
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
            return baseURL.appendingPathComponent("/gameday/team-stats/\(game.id)")
        case .matchExtra(let game):
            return baseURL.appendingPathComponent("/sports-v2/game-info/\(game.id)")
        case .match(let id):
            return baseURL.appendingPathComponent("/sports-v2/game-info/\(id)")

        case .teams: return baseURL.appendingPathComponent("/site/settings")
        case .teamLineup(let team):
            return baseURL.appendingPathComponent("/sports/players/\(team.id)")

        case .standings(let ssgtUuid):
            return baseURL.appendingPathComponent("/sports/league-standings")
                .appending(queryItems: [.init(name: "ssgtUuid", value: ssgtUuid)])

        case .player(let id):
            return baseURL.appendingPathComponent("/sports/player/profile-page")
                .appending(queryItems: [.init(name: "playerUuid", value: id)])
        case .playerGameLog(let player):
            return baseURL.appendingPathComponent(
                "/statistics-v2/athlete/playerProfile_gameLog"
            )
            .appending(queryItems: [.init(name: "playerUuid", value: player.uuid)])

        case .siteSettings:
            return baseURL.appendingPathComponent("/sports/season-series-game-types-filter")
        }
    }
}

enum LiveEndpoint: Endpoints {
    case playByPlay(Game)

    func url(using configuration: EndpointConfiguration) -> URL {
        let baseURL = configuration.liveBaseURL
        switch self {
        case .playByPlay(let game):
            return baseURL.appendingPathComponent("/play-by-play/by-game-uuid/\(game.id)")
        }
    }
}

enum BroadcasterEndpoint: Endpoints {
    case live

    func url(using configuration: EndpointConfiguration) -> URL {
        let baseURL = configuration.broadcasterBaseURL
        switch self {
        case .live: return baseURL.appendingPathComponent("/live/game")
        }
    }
}
