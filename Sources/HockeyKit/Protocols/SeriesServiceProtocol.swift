//
//  SeriesServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

protocol SeriesServiceProtocol {
    func getCurrentSeries() async throws -> Series?
}
