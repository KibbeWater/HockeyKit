//
//  GoalEvent.swift
//
//
//  Created by KibbeWater on 3/24/24.
//

import Foundation

public struct GoalEvent: PBPEventProtocol {
    public let gameId: Int
    public let gameSourceId: String
    public let gameUuid: String
    public let period: Int
    public let realWorldTime: Date
    public let type: PBPEventType
    
    // Unique fields for a "goal" event
    public let player: PBPlayer
    public let homeGoals: Int
    public let awayGoals: Int
    public let goalSection: Int
    public let isEmptyNetGoal: Bool
    public let assists: AssistDictionary?
    public let locationX: Int
    public let locationY: Int
    
    public struct AssistDictionary: Codable {
        public let first: PBPlayer?
        public let second: PBPlayer?
    }
    
    public enum AssistType: String {
        case first
        case second
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all the simple properties directly
        gameId = try container.decode(Int.self, forKey: .gameId)
        gameSourceId = try container.decode(String.self, forKey: .gameSourceId)
        gameUuid = try container.decode(String.self, forKey: .gameUuid)
        period = try container.decode(Int.self, forKey: .period)
        
        let _realWorldTime = try container.decode(String.self, forKey: .realWorldTime)
        realWorldTime = DateFormatter.iso8601Full.date(from: _realWorldTime) ?? Date.distantPast
        
        type = try container.decode(PBPEventType.self, forKey: .type)
        
        // Decode the unique fields for a "goal" event
        player = try container.decode(PBPlayer.self, forKey: .player)
        homeGoals = try container.decode(Int.self, forKey: .homeGoals)
        awayGoals = try container.decode(Int.self, forKey: .awayGoals)
        goalSection = try container.decode(Int.self, forKey: .goalSection)
        isEmptyNetGoal = try container.decode(Bool.self, forKey: .isEmptyNetGoal)
        assists = try container.decodeIfPresent(AssistDictionary.self, forKey: .assists)
        locationX = try container.decode(Int.self, forKey: .locationX)
        locationY = try container.decode(Int.self, forKey: .locationY)
    }
    
    private enum CodingKeys: String, CodingKey {
        case gameId
        case gameSourceId
        case gameUuid
        case period
        case realWorldTime
        case type
        // Unique fields for a "goal" event
        case player
        case homeGoals
        case awayGoals
        case goalSection
        case isEmptyNetGoal
        case assists
        case locationX
        case locationY
    }
}
