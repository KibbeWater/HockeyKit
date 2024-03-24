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
