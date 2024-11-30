//
//  PBPEventProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

import Foundation

public struct PBPEvents: Sendable {
    public let events: [PBPEventProtocol]
    
    public func getEvents<T: PBPEventProtocol>(ofType type: PBPEventType) -> [T] {
        return events.filter({ type == $0.type }) as! [T]
    }
}

public protocol PBPEventProtocol: Codable, Sendable {
    var gameId: Int { get }
    var gameSourceId: String { get }
    var gameUuid: String { get }
    var period: Int { get }
    var realWorldTime: Date { get }
    var type: PBPEventType { get }
}

public enum PBPEventType: String, Codable {
    case goal = "goal"
    case goalkeeper = "goalkeeper"
    case penalty = "penalty"
    case period = "period"
    case shot = "shot"
    case timeout = "timeout"
}
