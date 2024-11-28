//
//  Team.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

public struct Team: Codable, Sendable {
    public var name: String
    public var code: String
    public var result: Int
}
