//
//  PeriodEvent.swift
//
//
//  Created by KibbeWater on 3/24/24.
//

import Foundation

struct PeriodEvent: PBPEventProtocol {
    let gameId: Int
    let gameSourceId: String
    let gameUuid: String
    let period: Int
    let realWorldTime: String
    let type: String

    // Unique fields for a period event
    let started: Bool
    let finished: Bool
    let startedAt: String?
    let finishedAt: String?
}
