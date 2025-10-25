//
//  GameData.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Foundation

public struct GameData: Codable, Sendable {
    public var gameOverview: GameOverview
    
    public struct GameOverview: Codable, Equatable, Sendable {
        public var gameId: Int?
        public var homeTeam: TeamData
        public var awayTeam: TeamData
        public var homeGoals: Int
        public var awayGoals: Int
        public var state: GameState
        public var gameUuid: String
        public var time: GameTime
        
        public enum GameState: String, Codable, Sendable {
            case starting = "NotStarted"
            case ongoing = "Ongoing"
            case onbreak = "PeriodBreak"
            case overtime = "Overtime"
            case ended = "GameEnded"
        }
        
        public struct TeamData: Codable, Equatable, Sendable, TeamTransformable {
            public var gameId: Int
            public var place: PlaceType
            public var score: Int
            public var teamId: String
            public var teamName: String
            public var teamCode: String
            public var gameUuid: String
            
            public func toTeam() -> Team {
                Team(
                    name: teamName,
                    code: teamCode,
                    result: score
                )
            }
            
            public enum PlaceType: String, Codable, Sendable {
                case home = "home"
                case away = "away"
            }
        }
        
        public struct GameTime: Codable, Equatable, Sendable {
            public var period: Int
            public var periodTime: String
            public var periodEnd: Date?
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(period, forKey: .period)
                try container.encode(periodTime, forKey: .periodTime)
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                period = try container.decode(Int.self, forKey: .period)
                periodTime = try container.decode(String.self, forKey: .periodTime)
                periodEnd = estimatedEndTime(periodTime)
            }
            
            public init(period: Int, periodTime: String, periodEnd: Date?) {
                self.period = period
                self.periodTime = periodTime
                self.periodEnd = periodEnd
            }
            
            // Coding keys for mapping between struct properties and JSON keys
            private enum CodingKeys: String, CodingKey {
                case period
                case periodTime
            }
            
            public func estimatedEndTime(_ gameDuration: String) -> Date? {
                let formatter = DateFormatter()
                formatter.dateFormat = "mm:ss"
                
                guard let durationDate = formatter.date(from: gameDuration) else {
                    return nil
                }
                
                // Set the maximum game duration to 20 minutes
                let maxGameDuration: TimeInterval = 20 * 60
                
                // Calculate the end time by adding the game duration to the current time
                let estimatedEndDate = Date().addingTimeInterval(durationDate.timeIntervalSinceReferenceDate - maxGameDuration)
                
                return estimatedEndDate
            }
        }
        
        public init(gameId: Int? = nil, homeTeam: TeamData, awayTeam: TeamData, homeGoals: Int, awayGoals: Int, state: GameState, gameUuid: String, time: GameTime) {
            self.gameId = gameId
            self.homeTeam = homeTeam
            self.awayTeam = awayTeam
            self.homeGoals = homeGoals
            self.awayGoals = awayGoals
            self.state = state
            self.gameUuid = gameUuid
            self.time = time
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<GameData.GameOverview.CodingKeys> = try decoder.container(keyedBy: GameData.GameOverview.CodingKeys.self)

            // Handle gameId which can be either Int or String from the API
            if let gameIdInt = try? container.decodeIfPresent(Int.self, forKey: .gameId) {
                self.gameId = gameIdInt
            } else if let gameIdString = try? container.decodeIfPresent(String.self, forKey: .gameId) {
                self.gameId = Int(gameIdString)
            } else {
                self.gameId = nil
            }

            self.homeTeam = try container.decode(GameData.GameOverview.TeamData.self, forKey: .homeTeam)
            self.awayTeam = try container.decode(GameData.GameOverview.TeamData.self, forKey: .awayTeam)
            self.homeGoals = try container.decode(Int.self, forKey: .homeGoals)
            self.awayGoals = try container.decode(Int.self, forKey: .awayGoals)
            self.state = try container.decode(GameData.GameOverview.GameState.self, forKey: .state)
            self.gameUuid = try container.decode(String.self, forKey: .gameUuid)
            self.time = try container.decode(GameData.GameOverview.GameTime.self, forKey: .time)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(gameId, forKey: .gameId)
            try container.encode(homeTeam, forKey: .homeTeam)
            try container.encode(awayTeam, forKey: .awayTeam)
            try container.encode(homeGoals, forKey: .homeGoals)
            try container.encode(awayGoals, forKey: .awayGoals)
            try container.encode(state, forKey: .state)
            try container.encode(gameUuid, forKey: .gameUuid)
            try container.encode(time, forKey: .time)
        }

        enum CodingKeys: String, CodingKey {
            case gameId
            case homeTeam
            case awayTeam
            case homeGoals
            case awayGoals
            case state
            case gameUuid
            case time
        }
    }
}

