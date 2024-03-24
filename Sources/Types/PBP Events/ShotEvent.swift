//
//  ShotEvent.swift
//
//
//  Created by KibbeWater on 3/24/24.
//

import Foundation

struct ShotEvent: PBPEventProtocol {
    let gameId: Int
    let gameSourceId: String
    let gameUuid: String
    let period: Int
    let realWorldTime: String
    let type: String
}
