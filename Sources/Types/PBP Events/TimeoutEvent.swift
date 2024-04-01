//
//  TimeoutEvent.swift
//
//
//  Created by KibbeWater on 3/24/24.
//

import Foundation

public struct TimeoutEvent: PBPEventProtocol {
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
        
        time = try container.decode(String.self, forKey: .time)
        homeTeam = try container.decode(PBPTeam.self, forKey: .homeTeam)
        awayTeam = try container.decode(PBPTeam.self, forKey: .awayTeam)
        eventTeam = try container.decode(PBPEventTeam.self, forKey: .eventTeam)
    }
}
