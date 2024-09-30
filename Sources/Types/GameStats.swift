//
//  GameStats.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 30/9/24.
//

import Foundation

public enum GameStatKey: String, Codable {
    case goals = "G"
    case shotsOnGoal = "SOG"
    case saves = "Saves"
    case wonFaceoffs = "FOW"
}

public struct GameStatsAPIResponse: Codable {
    public var home: GameStats
    public var away: GameStats
}

public struct GameStatKV: Codable {
    public var key: String
    public var value: Int
}

public struct GameStatsPeriod: Codable {
    public var period: Int
    public var stats: [GameStatKV]
    
    public enum CodingKeys: String, CodingKey {
        case period
        case stats = "parsedTotalStatistics"
    }
}

public struct GameStats: Codable {
    public var gameUuid: String
    public var teamId: String
    public var teamCode: String
    public var teamName: String
    public var statistics: [GameStatsPeriod]
    
    public func getStat(for key: GameStatKey) -> Int? {
        statistics.first(where: { $0.period == 0 })?.stats.first(where: { $0.key == key.rawValue })?.value
    }
}
