//
//  PlayerGameLog.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

public struct PlayerGameLog: Codable, Hashable, Sendable {
    public let season: Int
    public let gameType: PlayerGameType
    public let info: PlayerGameStatInfo
    public let gamesPlayed: Int?
    public let wins: Int?
    public let draws: Int?
    public let losses: Int?
    
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
        self.gamesPlayed = try container.decodeIfPresent(Int.self, forKey: .gamesPlayed)
        self.info = try container.decode(PlayerGameStatInfo.self, forKey: .info)
        self.wins = try container.decodeIfPresent(Int.self, forKey: .wins)
        self.draws = try container.decodeIfPresent(Int.self, forKey: .draws)
        self.losses = try container.decodeIfPresent(Int.self, forKey: .losses)
        
        self.gameType = (try? container.decode(PlayerGameType.self, forKey: .gameType)) ?? .unknown
    }
    
    public enum PlayerGameType: String, Codable, Sendable {
        case regular = "Elitserien"
        case finals = "SMSlutspel"
        case unknown
    }

    public struct PlayerGameStatInfo: Codable, Hashable, Sendable {
        public let teamId: String
    }
}
