//
//  GoalEvent.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
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
    public let time: String
    public let player: PBPlayer
    public let homeGoals: Int
    public let awayGoals: Int
    public let homeTeam: PBPTeam
    public let awayTeam: PBPTeam
    public let eventTeam: PBPEventTeam
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
        realWorldTime = DateUtils.parseISODate(_realWorldTime) ?? Date.distantPast
        
        type = try container.decode(PBPEventType.self, forKey: .type)
        
        // Decode the unique fields for a "goal" event
        time = try container.decode(String.self, forKey: .time)
        player = try container.decode(PBPlayer.self, forKey: .player)
        homeGoals = try container.decode(Int.self, forKey: .homeGoals)
        awayGoals = try container.decode(Int.self, forKey: .awayGoals)
        homeTeam = try container.decode(PBPTeam.self, forKey: .homeTeam)
        awayTeam = try container.decode(PBPTeam.self, forKey: .awayTeam)
        eventTeam = try container.decode(PBPEventTeam.self, forKey: .eventTeam)
        goalSection = try container.decode(Int.self, forKey: .goalSection)
        isEmptyNetGoal = try container.decode(Bool.self, forKey: .isEmptyNetGoal)
        assists = try container.decodeIfPresent(AssistDictionary.self, forKey: .assists)
        locationX = try container.decode(Int.self, forKey: .locationX)
        locationY = try container.decode(Int.self, forKey: .locationY)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.gameId, forKey: .gameId)
        try container.encode(self.gameSourceId, forKey: .gameSourceId)
        try container.encode(self.gameUuid, forKey: .gameUuid)
        try container.encode(self.period, forKey: .period)
        try container.encode(DateUtils.formatISODate(self.realWorldTime), forKey: .realWorldTime)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.time, forKey: .time)
        try container.encode(self.player, forKey: .player)
        try container.encode(self.homeTeam, forKey: .homeTeam)
        try container.encode(self.awayTeam, forKey: .awayTeam)
        try container.encode(self.eventTeam, forKey: .eventTeam)
        try container.encode(self.homeGoals, forKey: .homeGoals)
        try container.encode(self.awayGoals, forKey: .awayGoals)
        try container.encode(self.goalSection, forKey: .goalSection)
        try container.encode(self.isEmptyNetGoal, forKey: .isEmptyNetGoal)
        try container.encodeIfPresent(self.assists, forKey: .assists)
        try container.encode(self.locationX, forKey: .locationX)
        try container.encode(self.locationY, forKey: .locationY)
    }
    
    private enum CodingKeys: String, CodingKey {
        case gameId
        case gameSourceId
        case gameUuid
        case period
        case realWorldTime
        case type
        // Unique fields for a "goal" event
        case time
        case player
        case homeTeam
        case awayTeam
        case eventTeam
        case homeGoals
        case awayGoals
        case goalSection
        case isEmptyNetGoal
        case assists
        case locationX
        case locationY
    }
}
