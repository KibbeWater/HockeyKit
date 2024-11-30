//
//  GameStats.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

public struct GameStats: Codable, Sendable {
    public var home: TeamStats
    public var away: TeamStats
    
    public struct TeamStats: Codable, Sendable {
        public var gameUuid: String
        public var teamId: String
        public var teamCode: String
        public var teamName: String
        public var statistics: [GameStatsPeriod]
        
        public func getStat(for key: GameStatKey) -> Int? {
            statistics.first(where: { $0.period == 0 })?.stats.first(where: { $0.key == key.rawValue })?.value
        }
        
        public struct GameStatsPeriod: Codable, Sendable {
            public var period: Int
            public var stats: [GameStatKV]
            
            public enum CodingKeys: String, CodingKey {
                case period
                case stats = "parsedTotalStatistics"
            }
        }
        
        public enum GameStatKey: String, Codable, Sendable {
            case goals = "G"
            case shotsOnGoal = "SOG"
            case saves = "Saves"
            case wonFaceoffs = "FOW"
        }

        public struct GameStatKV: Codable, Sendable {
            public var key: String
            public var value: Int
        }
    }
}
