//
//  GameStats.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

public struct GameStats: Codable {
    public var home: TeamStats
    public var away: TeamStats
    
    public struct TeamStats: Codable {
        public var gameUuid: String
        public var teamId: String
        public var teamCode: String
        public var teamName: String
        public var statistics: [GameStatsPeriod]
        
        public func getStat(for key: GameStatKey) -> Int? {
            statistics.first(where: { $0.period == 0 })?.stats.first(where: { $0.key == key.rawValue })?.value
        }
        
        public struct GameStatsPeriod: Codable {
            public var period: Int
            public var stats: [GameStatKV]
            
            public enum CodingKeys: String, CodingKey {
                case period
                case stats = "parsedTotalStatistics"
            }
        }
        
        public enum GameStatKey: String, Codable {
            case goals = "G"
            case shotsOnGoal = "SOG"
            case saves = "Saves"
            case wonFaceoffs = "FOW"
        }

        public struct GameStatKV: Codable {
            public var key: String
            public var value: Int
        }
    }
}
