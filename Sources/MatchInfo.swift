//
//  MatchInfo.swift
//
//
//  Created by KibbeWater on 12/30/23.
//

import Foundation

public struct Game: Identifiable, Equatable, Decodable {
    public var id: String // uuid
    public var date: Date
    public var played: Bool
    public var overtime: Bool
    public var shootout: Bool
    public var ssgtUuid: String
    public var seriesCode: Series
    public var venue: String
    public var homeTeam: Team
    public var awayTeam: Team
    public var liveGameUrl: String
    
    public struct Team: Codable {
        public var name: String
        public var code: String
        public var result: Int
        public var logo: String
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
            date: Date(),
            played: true,
            overtime: true,
            shootout: false,
            ssgtUuid: "qeX-3mMev7bgG",
            seriesCode: .SHL,
            venue: "Be-Ge Hockey Center",
            homeTeam: Game.Team(
                name: "IK Oskarshamn",
                code: "IKO",
                result: 2,
                logo: "https://sportality.cdn.s8y.se/team-logos/iko1_iko.svg"
            ),
            awayTeam: Game.Team(
                name: "HV71",
                code: "HV71",
                result: 3,
                logo: "https://sportality.cdn.s8y.se/team-logos/hv711_hv71.svg"
            ),
            liveGameUrl: ""
        )
    }
    
    public init(id: String, date: Date, played: Bool, overtime: Bool, shootout: Bool, ssgtUuid: String, seriesCode: Series, venue: String, homeTeam: Team, awayTeam: Team, liveGameUrl: String) {
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
        self.liveGameUrl = liveGameUrl
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let _date = try container.decode(String.self, forKey: .date)
        let _time = try container.decode(String.self, forKey: .time)
        date = dateFormatter.date(from: "\(_date)T\(_time):00+0100") ?? Date.distantPast
        Logging.shared.log("\(_date)T\(_time):00+0100\n    \(date.ISO8601Format())")
        
        played = try container.decode(Bool.self, forKey: .played)
        overtime = try container.decode(Bool.self, forKey: .overtime)
        shootout = try container.decode(Bool.self, forKey: .shootout)
        ssgtUuid = try container.decode(String.self, forKey: .ssgtUuid)
        seriesCode = try container.decode(Series.self, forKey: .seriesCode)
        venue = try container.decode(String.self, forKey: .venue)
        homeTeam = try container.decode(Team.self, forKey: .homeTeam)
        awayTeam = try container.decode(Team.self, forKey: .awayTeam)
        liveGameUrl = try container.decode(String.self, forKey: .liveGameUrl)
    }

    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case date
        case time
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

public class MatchInfo: ObservableObject {
    private var url: String = "https://www.shl.se/api"
    @Published public var latestMatches: [Game] = []
    
    public init() {}
    
    public func getLatest() async throws {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "\(url)/gameday/gameheader")!)
            print(data)
            let decoder = JSONDecoder()
            let game = try decoder.decode([String: [Game]].self, from: data)
            
            var newMatches: [Game] = []
            game.forEach { (key: String, value: [Game]) in
                if let game = value.first {
                    newMatches.append(game)
                }
            }
            newMatches = newMatches.sorted { $0.date < $1.date }
            
            let _matches = newMatches
            Task {
                DispatchQueue.main.async {
                    self.latestMatches = _matches
                }
            }
        } catch let error {
            print("ERR!")
            print(error)
        }
    }
    
    public func getMatch(_ matchId: String) async throws -> GameOverview? {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "\(url)/gameday/game-overview/\(matchId)")!)
            
            let decoder = JSONDecoder()
            let game = try decoder.decode(GameOverview.self, from: data)
            
            return game
        } catch let error {
            print("ERR!")
            print(error)
            return nil
        }
    }
}
