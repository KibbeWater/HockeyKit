//
//  GoalkeeperEvent.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//


import Foundation

public struct GoalkeeperEvent: PBPEventProtocol {
    public let gameId: Int
    public let gameSourceId: String
    public let gameUuid: String
    public let period: Int
    public let realWorldTime: Date
    public let type: PBPEventType

    // Unique fields for a goalkeeper event
    public let isEntering: Bool
    public let time: String
    public let eventTeam: PBPEventTeam
    public let player: PBPlayer
    
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
        isEntering = try container.decode(Bool.self, forKey: .isEntering)
        time = try container.decode(String.self, forKey: .time)
        eventTeam = try container.decode(PBPEventTeam.self, forKey: .eventTeam)
        player = try container.decode(PBPlayer.self, forKey: .player)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.gameId, forKey: .gameId)
        try container.encode(self.gameSourceId, forKey: .gameSourceId)
        try container.encode(self.gameUuid, forKey: .gameUuid)
        try container.encode(self.period, forKey: .period)
        try container.encode(DateUtils.formatISODate(self.realWorldTime), forKey: .realWorldTime)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.isEntering, forKey: .isEntering)
        try container.encode(self.time, forKey: .time)
        try container.encode(self.eventTeam, forKey: .eventTeam)
        try container.encode(self.player, forKey: .player)
    }
    
    public enum CodingKeys: CodingKey {
        case gameId
        case gameSourceId
        case gameUuid
        case period
        case realWorldTime
        case type
        case isEntering
        case time
        case eventTeam
        case player
    }
}
