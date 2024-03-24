//
//  PBPlayer.swift
//
//
//  Created by KibbeWater on 3/24/24.
//

import Foundation

struct PBPlayer: Codable {
    let playerId: String
    let firstName: String
    let familyName: String
    let jerseyToday: String
    var statistics: [PlayerStatistic]?
    
    struct PlayerStatistic: Codable {
        let key: String
        let value: String
    }
}
