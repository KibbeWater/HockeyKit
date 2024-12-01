//
//  PenaltyEvent.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//


import Foundation

public struct PenaltyEvent: PBPEventProtocol {
    public let gameId: Int
    public let gameSourceId: String
    public let gameUuid: String
    public let period: Int
    public let realWorldTime: Date
    public let type: PBPEventType

    // Unique fields for a penalty event
    public let time: String
    public let player: PBPlayer?
    public let eventTeam: PBPEventTeam
    public let offence: String
    public let didRenderInPenaltyShot: Bool
    public let variant: PenaltyVariant
    
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
        player = try container.decodeIfPresent(PBPlayer.self, forKey: .player)
        eventTeam = try container.decode(PBPEventTeam.self, forKey: .eventTeam)
        offence = try container.decode(String.self, forKey: .offence)
        didRenderInPenaltyShot = try container.decode(Bool.self, forKey: .didRenderInPenaltyShot)
        variant = try container.decode(PenaltyVariant.self, forKey: .variant)
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
        try container.encodeIfPresent(self.player, forKey: .player)
        try container.encode(self.eventTeam, forKey: .eventTeam)
        try container.encode(self.offence, forKey: .offence)
        try container.encode(self.didRenderInPenaltyShot, forKey: .didRenderInPenaltyShot)
        try container.encode(self.variant, forKey: .variant)
    }
    
    public enum CodingKeys: CodingKey {
        case gameId
        case gameSourceId
        case gameUuid
        case period
        case realWorldTime
        case type
        case time
        case player
        case eventTeam
        case offence
        case didRenderInPenaltyShot
        case variant
    }

    public struct PenaltyVariant: Codable, Sendable {
        public let shortName: String?
        public let minorTime: String?
        public let doubleMinorTime: String?
        public let benchTime: String?
        public let majorTime: String?
        public let misconductTime: String?
        public let gMTime: String?
        public let mPTime: String?
        public let description: String?
    }
}
