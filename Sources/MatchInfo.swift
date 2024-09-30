//
//  MatchInfo.swift
//
//
//  Created by KibbeWater on 12/30/23.
//

import Foundation

public struct GameExtraInfo: Decodable {
    public var gameInfo: GameInfo
    public var homeTeam: Team
    public var awayTeam: Team
    public var ssgtUuid: String
    
    public struct Team: Decodable {
        public var uuid: String
        public var names: TeamNames
        public var score: Int
        
        public struct TeamNames: Decodable {
            public var code: String
            public var long: String
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<GameExtraInfo.Team.CodingKeys> = try decoder.container(keyedBy: GameExtraInfo.Team.CodingKeys.self)
            self.uuid = try container.decode(String.self, forKey: GameExtraInfo.Team.CodingKeys.uuid)
            self.names = try container.decode(GameExtraInfo.Team.TeamNames.self, forKey: GameExtraInfo.Team.CodingKeys.names)
            self.score = (try? container.decode(Int.self, forKey: GameExtraInfo.Team.CodingKeys.score)) ?? 0
        }
        
        private enum CodingKeys: String, CodingKey {
            case uuid
            case names
            case score
        }
    }
    
    public struct GameInfo: Decodable {
        public var date: Date
        public var overtime: Bool
        public var shootout: Bool
        public var gameUuid: String
        public var state: GameStateInfo
        public var arenaName: String
        
        public enum GameStateInfo: String, Decodable {
            case post = "post_game"
            case pre = "pre_game"
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<GameExtraInfo.GameInfo.CodingKeys> = try decoder.container(keyedBy: GameExtraInfo.GameInfo.CodingKeys.self)
            
            let _date = try container.decode(String.self, forKey: .startDateTime)
            date = formatTimeFromISO(_date) ?? .distantPast

            self.overtime = try container.decode(Bool.self, forKey: .overtime)
            self.shootout = try container.decode(Bool.self, forKey: .shootout)
            self.gameUuid = try container.decode(String.self, forKey: .gameUuid)
            self.state = try container.decode(GameStateInfo.self, forKey: .state)
            self.arenaName = try container.decode(String.self, forKey: .arenaName)
        }
        
        private enum CodingKeys: String, CodingKey {
            case startDateTime
            case overtime
            case shootout
            case gameUuid
            case state
            case arenaName
        }
    }
}

public struct Game: Identifiable, Equatable, Hashable, Decodable {
    public var id: String // uuid
    public var date: Date
    public var played: Bool
    public var overtime: Bool
    public var shootout: Bool
    public var ssgtUuid: String
    public var seriesCode: Series
    public var venue: String?
    public var homeTeam: Team
    public var awayTeam: Team
    
    public func isLive() -> Bool {
        return !self.played && self.date < Date.now;
    }
    
    public struct Team: Codable, Hashable {
        public var name: String
        public var code: String
        public var result: Int
        
        init(name: String, code: String, result: Int) {
            self.name = name
            self.code = code
            self.result = result
        }
        
        init(_ team: TeamData) {
            self.name = team.teamName
            self.code = team.teamCode
            self.result = team.score
        }
        
        init(_ team: GameExtraInfo.Team) {
            self.name = team.names.long
            self.code = team.names.code
            self.result = team.score
        }
    }
    
    public enum Series: String, Codable {
        case SHL
        case SDHL
    }
    
    public static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func fakeData() -> Game {
        return Game(
            id: "qeX-4AC927yoX",
            date: Date.distantPast,
            played: true,
            overtime: true,
            shootout: false,
            ssgtUuid: "qeX-3mMev7bgG",
            seriesCode: .SHL,
            venue: "Be-Ge Hockey Center",
            homeTeam: Game.Team(
                name: "IK Oskarshamn",
                code: "IKO",
                result: 2
            ),
            awayTeam: Game.Team(
                name: "HV71",
                code: "HV71",
                result: 3
            )
        )
    }
    
    public init(_ game: GameExtraInfo) {
        self.id = game.gameInfo.gameUuid
        self.date = game.gameInfo.date
        self.played = game.gameInfo.state == .post
        self.overtime = game.gameInfo.overtime
        self.shootout = game.gameInfo.shootout
        self.ssgtUuid = game.ssgtUuid
        self.seriesCode = .SHL
        self.venue = game.gameInfo.arenaName
        self.homeTeam = .init(game.homeTeam)
        self.awayTeam = .init(game.awayTeam)
    }
    
    public init(id: String, date: Date, played: Bool, overtime: Bool, shootout: Bool, ssgtUuid: String, seriesCode: Series, venue: String?, homeTeam: Team, awayTeam: Team) {
        self.id = id
        self.date = date
        self.played = played
        self.overtime = overtime
        self.shootout = shootout
        self.ssgtUuid = ssgtUuid
        self.seriesCode = seriesCode
        self.venue = venue
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        
        let _date = try container.decode(String.self, forKey: .startDateTime)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "sv-SE")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        date = formatTimeFromDate(_date, formatter: dateFormatter) ?? .distantPast
        
        played = try container.decode(Bool.self, forKey: .played)
        overtime = try container.decode(Bool.self, forKey: .overtime)
        shootout = try container.decode(Bool.self, forKey: .shootout)
        ssgtUuid = try container.decode(String.self, forKey: .ssgtUuid)
        seriesCode = try container.decode(Series.self, forKey: .seriesCode)
        venue = try container.decodeIfPresent(String.self, forKey: .venue)
        homeTeam = try container.decode(Team.self, forKey: .homeTeam)
        awayTeam = try container.decode(Team.self, forKey: .awayTeam)
    }

    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
//        case date
//        case time
        case startDateTime
        case played
        case overtime
        case shootout
        case ssgtUuid
        case seriesCode
        case venue
        case homeTeam
        case awayTeam
        case liveGameUrl
    }
}

struct AnyPBPEvent: Decodable {
    let event: PBPEventProtocol
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        self.event = try EventFactory.decode(from: decoder)
    }
}

class EventFactory {
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

public class MatchInfo: ObservableObject {
    @Published public var latestMatches: [Game] = []
    
    public init() {}
    
    public func getLatest() async throws {
        let request = URLRequest(
            url: .init(string: "\(getBaseURL())/gameday/gameheader")!,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let game = try decoder.decode([String: [Game]].self, from: data)
        
        var newMatches: [Game] = game.flatMap { $1 }
        newMatches = newMatches.sorted { $0.date < $1.date }
        
        let _matches = newMatches
        await MainActor.run {
            self.latestMatches = _matches
        }
    }
    
    public func getMatch(_ matchId: String) async throws -> GameOverview? {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "\(getBaseURL())/gameday/game-overview/\(matchId)")!)
            
            let decoder = JSONDecoder()
            let game = try decoder.decode(GameOverview.self, from: data)
            
            return game
        } catch let error {
            print("ERR!")
            print(error)
            return nil
        }
    }
    
    public func getMatchExtra(_ matchId: String) async throws -> GameExtraInfo? {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "\(getBaseURL())/sports/game-info/\(matchId)")!)
            
            let decoder = JSONDecoder()
            let game = try decoder.decode(GameExtraInfo.self, from: data)
            
            return game
        } catch let error {
            print("ERR!")
            print(error)
            return nil
        }
    }
    
    public func getMatchPBP(_ matchId: String) async throws -> [PBPEventProtocol]? {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://game-data.s8y.se/play-by-play/by-game-uuid/\(matchId)")!)
            
            let decoder = JSONDecoder()
            
            let decodedEvents = try decoder.decode([AnyPBPEvent].self, from: data)
            var events = decodedEvents.map { $0.event }
            events = events.sorted { $0.realWorldTime < $1.realWorldTime }
            
            return events
        } catch let error {
            print("ERR!")
            print(error)
            return nil
        }
    }
    
    public func getSchedule(_ season: Season, gameType: GameType = .regular, team: String? = nil) async throws -> SeasonSchedule? {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "\(getBaseURL())/sports/game-info?seasonUuid=\(season.uuid)&seriesUuid=qQ9-bb0bzEWUk&gameTypeUuid=\(gameType.rawValue)\(team == nil ? "" : "&teams[]=\(team!)")&gamePlace=all&played=all")!)
        
        let decoder = JSONDecoder()
        let game = try decoder.decode(SeasonSchedule.self, from: data)
        
        return game
    }
    
    public func getSeason() async throws -> SeasonAPIResponse? {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "\(getBaseURL())/sports/season-series-game-types-filter")!)
            
            let decoder = JSONDecoder()
            let game = try decoder.decode(SeasonAPIResponse.self, from: data)
            
            return game
        } catch let error {
            print("ERR!")
            print(error)
            return nil
        }
    }
    
    public func getCurrentSeason() async throws -> Season? {
        guard let game = try await getSeason() else { return nil }
        
        return game.season.first
    }
    
    public func getGameStats(_ game: Game) async throws -> GameStatsAPIResponse? {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "\(getBaseURL())/gameday/team-stats/\(game.id)")!)
        
        let decoder = JSONDecoder()
        let game = try decoder.decode(GameStatsAPIResponse.self, from: data)
        
        return game
    }
}
