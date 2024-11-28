//
//  Game.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

protocol GameTransformable: Codable {
    func toGame() -> Game
}

public enum GameType: String {
    case regular = "qQ9-af37Ti40B"
    case qualifying = "qRf-347BaDIOc"
    case finals = "qQ9-7debq38kX"
}

public struct Game: Codable, Identifiable {
    public var id: String
    
    public var date: Date
    public var played: Bool
    public var overtime: Bool
    public var shootout: Bool
    
    public var homeTeam: Team
    public var awayTeam: Team
    
    public init(
        id: String,
        date: Date,
        played: Bool,
        overtime: Bool,
        shootout: Bool,
        homeTeam: Team,
        awayTeam: Team
    ) {
        self.id = id
        self.date = date
        self.played = played
        self.overtime = overtime
        self.shootout = shootout
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
    }
}
