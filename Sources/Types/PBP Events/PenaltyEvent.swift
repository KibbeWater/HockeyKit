//
//  PenaltyEvent.swift
//
//
//  Created by KibbeWater on 3/24/24.
//

import Foundation

struct PenaltyEvent: PBPEventProtocol {
    let gameId: Int
    let gameSourceId: String
    let gameUuid: String
    let period: Int
    let realWorldTime: String
    let type: String

    // Unique fields for a penalty event
    let offence: String
    let didRenderInPenaltyShot: Bool
    let variant: PenaltyVariant
}

struct PenaltyVariant: Codable {
    let shortName: String
    let minorTime: String?
    let doubleMinorTime: String?
    let benchTime: String?
    let majorTime: String?
    let misconductTime: String?
    let gMTime: String?
    let mPTime: String?
    let description: String
}
