//
//  Team.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

protocol TeamTransformable {
    func toTeam() -> Team
}

public struct Team: Codable, Sendable {
    public var name: String
    public var code: String
    public var result: Int
    
    public init(name: String, code: String, result: Int) {
        self.name = name
        self.code = code
        self.result = result
    }
}
