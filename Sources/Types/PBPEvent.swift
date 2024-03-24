//
//  PBPEvent.swift
//  Play By Play Events
//
//  Created by user242911 on 3/24/24.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

public protocol PBPEventProtocol: Codable {
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
}
