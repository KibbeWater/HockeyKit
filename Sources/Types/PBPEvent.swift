//
//  PBPEvent.swift
//  Play By Play Events
//
//  Created by user242911 on 3/24/24.
//

import Foundation

protocol PBPEventProtocol: Codable {
    var gameId: Int { get }
    var gameSourceId: String { get }
    var gameUuid: String { get }
    var period: Int { get }
    var realWorldTime: String { get }
    var type: String { get }
}
