//
//  SeriesServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

public protocol SeriesServiceProtocol {
    func getCurrentSeries() async throws -> Series?
}
