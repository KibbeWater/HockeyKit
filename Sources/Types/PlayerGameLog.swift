//
//  PlayerGameLog.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 4/10/24.
//

import Foundation

public enum PlayerGameType: String, Codable {
    case regular = "Elitserien"
    case finals = "SMSlutspel"
    case unknown
}

public struct PlayerGameStatInfo: Codable, Hashable {
    public let teamId: String
}

public struct PlayerGameStat: Codable, Hashable {
    public let season: Int
    public let gameType: PlayerGameType
    public let info: PlayerGameStatInfo
    public let gamesPlayed: Int
    public let wins: Int
    public let draws: Int
    public let losses: Int
    
    enum CodingKeys: String, CodingKey {
        case season = "Season"
        case gameType = "GameType"
        case info
        case gamesPlayed = "GP"
        case wins = "W"
        case draws = "T"
        case losses = "L"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.season = try container.decode(Int.self, forKey: .season)
        self.gamesPlayed = try container.decode(Int.self, forKey: .gamesPlayed)
        self.info = try container.decode(PlayerGameStatInfo.self, forKey: .info)
        self.wins = try container.decode(Int.self, forKey: .wins)
        self.draws = try container.decode(Int.self, forKey: .draws)
        self.losses = try container.decode(Int.self, forKey: .losses)
        
        self.gameType = (try? container.decode(PlayerGameType.self, forKey: .gameType)) ?? .unknown
    }
}

public struct PlayerGameLog: Codable {
    public let stats: [PlayerGameStat]
}
