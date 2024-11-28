//
//  Season.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

import Foundation

public struct Season: Codable {
    public struct Name: Codable {
        let language: String
        let translation: String
    }

    public let uuid: String
    public let code: String
    public let names: [Name]
    public let createdBy: String?
    public let deleted: Bool

    // Internal properties for date parsing
    private let createdAt: String?
    private let lastModified: String?

    // Computed properties for public use
    public var createdDate: Date? {
        guard let createdAt = createdAt else { return nil }
        return ISO8601DateFormatter().date(from: createdAt)
    }

    public var lastModifiedDate: Date? {
        guard let lastModified = lastModified else { return nil }
        return ISO8601DateFormatter().date(from: lastModified)
    }
}
