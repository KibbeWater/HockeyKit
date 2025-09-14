//
//  SeasonServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

public protocol SeasonServiceProtocol {
    func getSeasons() async throws -> [Season]
    func getCurrent() async throws -> Season
    func getCurrentSsgt() async throws -> String
}
