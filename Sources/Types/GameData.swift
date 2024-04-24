//
//  GameData.swift
//  
//
//  Created by KibbeWater on 12/30/23.
//

import Foundation

public enum PlaceType: String, Codable {
    case home = "home"
    case away = "away"
}

public enum GameState: String, Codable {
    case starting = "NotStarted"
    case ongoing = "Ongoing"
    case onbreak = "PeriodBreak"
    case overtime = "Overtime"
    case ended = "GameEnded"
}

public struct TeamData: Codable, Equatable {
    public var gameId: Int
    public var place: PlaceType
    public var score: Int
    public var teamId: String
    public var teamName: String
    public var teamCode: String
    public var gameUuid: String
}

public struct GameTime: Codable, Equatable {
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
    
    init(period: Int, periodTime: String, periodEnd: Date?) {
        self.period = period
        self.periodTime = periodTime
        self.periodEnd = periodEnd
    }
    
    // Coding keys for mapping between struct properties and JSON keys
    private enum CodingKeys: String, CodingKey {
        case period
        case periodTime
    }
    
    func estimatedEndTime(_ gameDuration: String) -> Date? {
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

public struct GameOverview: Codable, Equatable {
    public var gameId: Int?
    public var homeTeam: TeamData
    public var awayTeam: TeamData
    public var homeGoals: Int
    public var awayGoals: Int
    public var state: GameState
    public var gameUuid: String
    public var time: GameTime
}

public struct GameData: Codable {
    public var gameOverview: GameOverview
}

public struct GameEvent {
    public var id: Int
    public var game: GameData
}

public extension GameOverview {
    static func generateFake() -> GameOverview {
        return GameOverview(
            homeTeam: TeamData(
                gameId: 533,
                place: .home,
                score: 2,
                teamId: "087a-087aTQv9u",
                teamName: "Frölunda",
                teamCode: "FHC",
                gameUuid: "qcz-3SPh13XBPn"
            ),
            awayTeam: TeamData(
                gameId: 533,
                place: .away,
                score: 3,
                teamId: "1a71-1a71gTHKh",
                teamName: "Luleå Hockey",
                teamCode: "LHF",
                gameUuid: "qcz-3SPh13XBPn"
            ),
            homeGoals: 2,
            awayGoals: 3,
            state: .ongoing,
            gameUuid: "qcz-3SPh13XBPn",
            time: GameTime(
                period: 2,
                periodTime: "07:27",
                periodEnd: Calendar.current.date(
                    byAdding: .second,
                    value: 447,
                    to: Date.now
                )
            )
        )
    }
}
