//
//  PBPlayer.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//


import Foundation

public struct PBPlayer: Codable, Sendable {
    public let playerId: String
    public let firstName: String
    public let familyName: String
    public let jerseyToday: String
    public var statistics: [PlayerStatistic]?
    
    public struct PlayerStatistic: Codable, Sendable {
        public let key: String
        public let value: String
    }
}

public struct PBPTeam: Codable, Sendable {
    public let teamId: String
    public let teamName: String
    public let teamCode: String
    public let score: Int
}

public struct PBPEventTeam: Codable, Sendable {
    public let teamId: String
    public let teamName: String
    public let teamCode: String
    public let place: PBPEventTeamType
}

public enum PBPEventTeamType: String, Codable, Sendable {
    case home
    case away
}
