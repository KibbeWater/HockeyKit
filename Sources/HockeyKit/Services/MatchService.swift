//
//  MatchService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

class MatchService: MatchServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    private let configuration: EndpointConfiguration

    init(networkManager: NetworkManagerProtocol, configuration: EndpointConfiguration = .default) {
        self.networkManager = networkManager
        self.configuration = configuration
    }
    
    func getLatest() async throws -> [Game] {
        let req: [String: [LatestGameResponse]] = try await networkManager.request(endpoint: Endpoint.matchesLatest, configuration: configuration)
        return req.flatMap { $1 }.map { $0.toGame() }
    }
    
    func getMatch(_ matchId: String) async throws -> GameExtra {
        let req: GameExtra = try await networkManager.request(endpoint: Endpoint.match(matchId), configuration: configuration)
        return req
    }
    
    func getSeasonSchedule(_ season: Season, series: Series) async throws -> [Game] {
        let network = networkManager
        let config = configuration
        
        async let regularResponse: ScheduleResponse = network.request(endpoint: Endpoint.matchesSchedule(season, series, .regular), configuration: config)
        async let finalsResponse: ScheduleResponse = network.request(endpoint: Endpoint.matchesSchedule(season, series, .finals), configuration: config)
        
        let regular = try? await regularResponse
        let finals = try? await finalsResponse
        
        let games = ((regular?.gameInfo ?? []) + (finals?.gameInfo ?? [])).map { $0.toGame() }
        
        return games
    }
    
    func getSeasonSchedule(_ season: Season, series: Series, withTeams teams: [String]) async throws -> [Game] {
        let network = networkManager
        let config = configuration
        
        async let regularResponse: ScheduleResponse = network.request(endpoint: Endpoint.matchesSchedule(season, series, .regular, teams), configuration: config)
        async let finalsResponse: ScheduleResponse = network.request(endpoint: Endpoint.matchesSchedule(season, series, .finals, teams), configuration: config)
        
        let regular = try? await regularResponse
        let finals = try? await finalsResponse
        
        let games = ((regular?.gameInfo ?? []) + (finals?.gameInfo ?? [])).map { $0.toGame() }
        
        return games
    }

    func getMatchStats(_ game: Game) async throws -> GameStats {
        guard game.played else { throw HockeyAPIError.gameNotPlayed }
        
        let stats: GameStats = try await networkManager.request(endpoint: Endpoint.matchStats(game), configuration: configuration)
        
        return stats
    }
    
    func getMatchExtra(_ game: Game) async throws -> GameExtra {
        guard game.played else { throw HockeyAPIError.gameNotPlayed }
        
        let extra: GameExtra = try await networkManager.request(endpoint: Endpoint.matchExtra(game), configuration: configuration)
        
        return extra
    }
    
    func getMatchPBP(_ game: Game) async throws -> PBPEvents {
        guard game.played || game.isLive() else { throw HockeyAPIError.gameNotPlayed }

        let pbp: [AnyPBPEvent] = try await networkManager.request(endpoint: LiveEndpoint.playByPlay(game), configuration: configuration)
        return PBPEvents(events: pbp.map { $0.event }.sorted(by: { $0.realWorldTime < $1.realWorldTime }))
    }
}

private struct ScheduleResponse: Codable {
    var gameInfo: [GameResponse]
    
    struct GameResponse: Codable, GameTransformable {
        func toGame() -> Game {
            Game(
                id: uuid,
                date: DateUtils.parseISODate(startDateTime) ?? .distantPast,
                played: state == "post-game",
                overtime: overtime,
                shootout: shootout,
                venue: venueInfo.name,
                homeTeam: Team(
                    name: homeTeamInfo.names?.long ?? "TBD",
                    code: homeTeamInfo.code,
                    result: homeTeamInfo.score ?? 0
                ),
                awayTeam: Team(
                    name: awayTeamInfo.names?.long ?? "TBD",
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
        
        var venueInfo: VenueInfo
        
        var homeTeamInfo: TeamResponse
        var awayTeamInfo: TeamResponse
        
        struct TeamResponse: Codable {
            var code: String
            var score: Int?
            var names: NameResponse?
            
            init(from decoder: any Decoder) throws {
                let container: KeyedDecodingContainer<ScheduleResponse.GameResponse.TeamResponse.CodingKeys> = try decoder.container(keyedBy: ScheduleResponse.GameResponse.TeamResponse.CodingKeys.self)
                self.code = try container.decodeIfPresent(String.self, forKey: ScheduleResponse.GameResponse.TeamResponse.CodingKeys.code) ?? "TBD"
                self.score = try? container.decodeIfPresent(Int.self, forKey: ScheduleResponse.GameResponse.TeamResponse.CodingKeys.score)
                self.names = try container.decodeIfPresent(ScheduleResponse.GameResponse.TeamResponse.NameResponse.self, forKey: ScheduleResponse.GameResponse.TeamResponse.CodingKeys.names)
            }
            
            struct NameResponse: Codable {
                var long: String
            }
        }
        
        struct VenueInfo: Codable {
            var name: String
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<ScheduleResponse.GameResponse.CodingKeys> = try decoder.container(keyedBy: ScheduleResponse.GameResponse.CodingKeys.self)
            self.uuid = try container.decode(String.self, forKey: ScheduleResponse.GameResponse.CodingKeys.uuid)
            self.state = try container.decode(String.self, forKey: ScheduleResponse.GameResponse.CodingKeys.state)
            self.startDateTime = try container.decode(String.self, forKey: ScheduleResponse.GameResponse.CodingKeys.startDateTime)
            self.overtime = try container.decode(Bool.self, forKey: .overtime)
            self.shootout = try container.decode(Bool.self, forKey: .shootout)
            self.venueInfo = try container.decode(ScheduleResponse.GameResponse.VenueInfo.self, forKey: .venueInfo)
            self.homeTeamInfo = try container.decode(ScheduleResponse.GameResponse.TeamResponse.self, forKey: .homeTeamInfo)
            self.awayTeamInfo = try container.decode(ScheduleResponse.GameResponse.TeamResponse.self, forKey: .awayTeamInfo)
        }
        
        enum CodingKeys: String, CodingKey {
            case uuid
            case state
            case startDateTime = "rawStartDateTime"
            case overtime
            case shootout
            case venueInfo
            case homeTeamInfo
            case awayTeamInfo
        }
    }
}

private struct LatestGameResponse: Codable, GameTransformable {
    func toGame() -> Game {
        Game(
            id: uuid,
            date: DateUtils.parseISODate(startDateTime) ?? .distantPast,
            played: played,
            overtime: overtime,
            shootout: shootout,
            venue: venue,
            homeTeam: homeTeam,
            awayTeam: awayTeam
        )
    }
    
    var uuid: String
    
    var startDateTime: String
    var played: Bool
    var overtime: Bool
    var shootout: Bool
    
    var venue: String
    
    var homeTeam: Team
    var awayTeam: Team
}

private struct AnyPBPEvent: Decodable {
    let event: PBPEventProtocol
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        self.event = try EventFactory.decode(from: decoder)
    }
}

private class EventFactory {
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
        case .penaltyShot:
            return try PenaltyShotEvent(from: decoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}
