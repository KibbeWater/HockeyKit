//
//  MatchService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation
import Cache

class MatchService: MatchServiceProtocol {
    private let networkManager: NetworkManager
    private let cache = initCache(forKey: "MatchService")
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getLatest() async throws -> [Game] {
        let req: [String: [LatestGameResponse]] = try await networkManager.request(endpoint: Endpoint.matchesLatest)
        return req.flatMap { $1 }.map({ $0.toGame() })
    }
    
    func getSeasonSchedule(_ season: Season) async throws -> [Game] {
        let scheduleStorage = cache.transformCodable(ofType: [Game].self)
        
        if let cachedSchedule = try? await scheduleStorage.async.object(forKey: season.uuid) {
            return cachedSchedule
        }
        
        let response: ScheduleResponse = try await networkManager.request(endpoint: Endpoint.matchesSchedule(season, .regular))
        let games = response.gameInfo.map({ $0.toGame() })
        
        try? await scheduleStorage.async.setObject(games, forKey: season.uuid, expiry: .seconds(24 * 60 * 60))
        
        return games
    }
    
    func getMatchStats(_ game: Game) async throws -> GameStats {
        guard game.played else { throw HockeyAPIError.gameNotPlayed }
        
        let statsStorage = cache.transformCodable(ofType: GameStats.self)
        
        if let stats = try? await statsStorage.async.object(forKey: "stats_\(game.id)") {
            return stats
        }
        
        let stats: GameStats = try await networkManager.request(endpoint: Endpoint.matchStats(game))
        try? await statsStorage.async.setObject(stats, forKey: "stats_\(game.id)")
        
        return stats
    }
    
    
    func getMatchPBP(_ game: Game) async throws -> PBPEvents {
        guard game.played else { throw HockeyAPIError.gameNotPlayed }

        let pbp: [AnyPBPEvent] = try await networkManager.request(endpoint: LiveEndpoint.playByPlay(game))
        return PBPEvents(events: pbp.map({ $0.event }).sorted(by: { $0.realWorldTime < $1.realWorldTime}))
    }
}

fileprivate struct ScheduleResponse: Codable {
    var gameInfo: [GameResponse]
    
    struct GameResponse: Codable, GameTransformable {
        func toGame() -> Game {
            Game(
                id: uuid,
                date: DateUtils.parseISODate(startDateTime) ?? .distantPast,
                played: state == "post-game",
                overtime: overtime,
                shootout: shootout,
                homeTeam: Team(
                    name: homeTeamInfo.names.long,
                    code: homeTeamInfo.code,
                    result: homeTeamInfo.score ?? 0
                ),
                awayTeam: Team(
                    name: awayTeamInfo.names.long,
                    code: awayTeamInfo.code,
                    result: awayTeamInfo.score ?? 0
                )
            )
        }
        
        var uuid: String
        
        var state: String
        
        var startDateTime: String
        var overtime: Bool
        var shootout: Bool
        
        var homeTeamInfo: TeamResponse
        var awayTeamInfo: TeamResponse
        
        struct TeamResponse: Codable {
            var code: String
            var score: Int?
            var names: NameResponse
            
            init(from decoder: any Decoder) throws {
                let container: KeyedDecodingContainer<ScheduleResponse.GameResponse.TeamResponse.CodingKeys> = try decoder.container(keyedBy: ScheduleResponse.GameResponse.TeamResponse.CodingKeys.self)
                self.code = try container.decode(String.self, forKey: ScheduleResponse.GameResponse.TeamResponse.CodingKeys.code)
                self.score = try? container.decodeIfPresent(Int.self, forKey: ScheduleResponse.GameResponse.TeamResponse.CodingKeys.score)
                self.names = try container.decode(ScheduleResponse.GameResponse.TeamResponse.NameResponse.self, forKey: ScheduleResponse.GameResponse.TeamResponse.CodingKeys.names)
            }
            
            struct NameResponse: Codable {
                var long: String
            }
        }
    }
}

fileprivate struct LatestGameResponse: Codable, GameTransformable {
    func toGame() -> Game {
        Game(
            id: uuid,
            date: DateUtils.parseISODate(startDateTime) ?? .distantPast,
            played: played,
            overtime: overtime,
            shootout: shootout,
            homeTeam: homeTeam,
            awayTeam: awayTeam
        )
    }
    
    var uuid: String
    
    var startDateTime: String
    var played: Bool
    var overtime: Bool
    var shootout: Bool
    
    var homeTeam: Team
    var awayTeam: Team
}

fileprivate struct AnyPBPEvent: Decodable {
    let event: PBPEventProtocol
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        self.event = try EventFactory.decode(from: decoder)
    }
}

fileprivate class EventFactory {
    static func decode(from decoder: Decoder) throws -> PBPEventProtocol {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PBPEventType.self, forKey: .type)
        switch type {
        case .goalkeeper:
            return try GoalkeeperEvent(from: decoder)
        case .goal:
            return try GoalEvent(from: decoder)
        case .penalty:
            return try PenaltyEvent(from: decoder)
        case .period:
            return try PeriodEvent(from: decoder)
        case .shot:
            return try ShotEvent(from: decoder)
        case .timeout:
            return try TimeoutEvent(from: decoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}
