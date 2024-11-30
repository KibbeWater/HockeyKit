//
//  GameExtra.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 1/12/24.
//

import Foundation

public struct GameExtra: Codable, Sendable {
    public var gameInfo: GameInfo
    public var homeTeam: Team
    public var awayTeam: Team
    public var ssgtUuid: String
    
    public struct Team: Codable, Sendable {
        public var uuid: String
        public var names: TeamNames
        public var score: Int
        
        public struct TeamNames: Codable, Sendable {
            public var code: String
            public var long: String
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Team.CodingKeys> = try decoder.container(keyedBy: Team.CodingKeys.self)
            self.uuid = try container.decode(String.self, forKey: Team.CodingKeys.uuid)
            self.names = try container.decode(Team.TeamNames.self, forKey: Team.CodingKeys.names)
            self.score = (try? container.decode(Int.self, forKey: Team.CodingKeys.score)) ?? 0
        }
        
        private enum CodingKeys: String, CodingKey {
            case uuid
            case names
            case score
        }
    }
    
    public struct GameInfo: Codable, Sendable {
        public var date: Date
        public var overtime: Bool
        public var shootout: Bool
        public var gameUuid: String
        public var state: GameStateInfo
        public var arenaName: String
        
        public enum GameStateInfo: String, Codable, Sendable {
            case post = "post_game"
            case pre = "pre_game"
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<GameInfo.CodingKeys> = try decoder.container(keyedBy: GameInfo.CodingKeys.self)
            
            let _date = try container.decode(String.self, forKey: .startDateTime)
            date = DateUtils.parseISODate(_date) ?? .distantPast

            self.overtime = try container.decode(Bool.self, forKey: .overtime)
            self.shootout = try container.decode(Bool.self, forKey: .shootout)
            self.gameUuid = try container.decode(String.self, forKey: .gameUuid)
            self.state = try container.decode(GameStateInfo.self, forKey: .state)
            self.arenaName = try container.decode(String.self, forKey: .arenaName)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(DateUtils.formatISODate(date), forKey: .startDateTime)
            try container.encode(overtime, forKey: .overtime)
            try container.encode(shootout, forKey: .shootout)
            try container.encode(gameUuid, forKey: .gameUuid)
            try container.encode(state, forKey: .state)
            try container.encode(arenaName, forKey: .arenaName)
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
