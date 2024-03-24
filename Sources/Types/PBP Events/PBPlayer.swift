//
//  PBPlayer.swift
//
//
//  Created by KibbeWater on 3/24/24.
//

import Foundation

public struct PBPlayer: Codable {
    public let playerId: String
    public let firstName: String
    public let familyName: String
    public let jerseyToday: String
    public var statistics: [PlayerStatistic]?
    
    public struct PlayerStatistic: Codable {
        public let key: String
        public let value: String
    }
}

public struct PBPTeam: Codable {
    public let teamId: String
    public let teamName: String
    public let teamCode: String
    public let score: Int
}

public struct PBPEventTeam: Codable {
    public let teamId: String
    public let teamName: String
    public let teamCode: String
    public let place: PBPEventTeamType
}

public enum PBPEventTeamType: String, Codable {
    case home
    case away
}
