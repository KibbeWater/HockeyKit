//
//  PenaltyShotEvent.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 9/1/25.
//

import Foundation

public struct PenaltyShotEvent: PBPEventProtocol {
    public let gameId: Int
    public let gameSourceId: String
    public let gameUuid: String
    public let period: Int
    public let realWorldTime: Date
    public let type: PBPEventType
    
    // Unique fields for a period event
    public let time: String
    public let homeTeam: PBPTeam
    public let awayTeam: PBPTeam
    public let eventTeam: PBPEventTeam
    public let player: PBPlayer
    public let goalSection: Int
    
    public let isGoal: Bool
    public let isGameWinningGoal: Bool
    public let shootoutIndex: Int
    public let shootoutScore: Score
    
    public struct Score: Codable, Sendable {
        public let homeGoals: Int
        public let awayGoals: Int
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
        
        time = try container.decode(String.self, forKey: .time)
        homeTeam = try container.decode(PBPTeam.self, forKey: .homeTeam)
        awayTeam = try container.decode(PBPTeam.self, forKey: .awayTeam)
        eventTeam = try container.decode(PBPEventTeam.self, forKey: .eventTeam)
        player = try container.decode(PBPlayer.self, forKey: .player)
        goalSection = try container.decode(Int.self, forKey: .goalSection)
        
        isGoal = try container.decode(Bool.self, forKey: .isGoal)
        isGameWinningGoal = try container.decode(Bool.self, forKey: .isGameWinningGoal)
        shootoutIndex = try container.decode(Int.self, forKey: .shootoutIndex)
        shootoutScore = try container.decode(Score.self, forKey: .shootoutScore)
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
        try container.encode(self.homeTeam, forKey: .homeTeam)
        try container.encode(self.awayTeam, forKey: .awayTeam)
        try container.encode(self.eventTeam, forKey: .eventTeam)
        try container.encode(self.player, forKey: .player)
        try container.encode(self.goalSection, forKey: .goalSection)
    }
    
    enum CodingKeys: CodingKey {
        case gameId
        case gameSourceId
        case gameUuid
        case period
        case realWorldTime
        case type
        case time
        case homeTeam
        case awayTeam
        case eventTeam
        case player
        case goalSection
        case isGoal
        case isGameWinningGoal
        case shootoutScore
        case shootoutIndex
    }
}
