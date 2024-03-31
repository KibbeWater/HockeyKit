//
//  PenaltyEvent.swift
//
//
//  Created by KibbeWater on 3/24/24.
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
        realWorldTime = DateFormatter.iso8601Full.date(from: _realWorldTime) ?? Date.distantPast
        
        type = try container.decode(PBPEventType.self, forKey: .type)
        
        // Decode the unique fields for a "goal" event
        offence = try container.decode(String.self, forKey: .offence)
        didRenderInPenaltyShot = try container.decode(Bool.self, forKey: .didRenderInPenaltyShot)
        variant = try container.decode(PenaltyVariant.self, forKey: .variant)
    }
}

public struct PenaltyVariant: Codable {
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
