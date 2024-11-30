//
//  StandingServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

public protocol StandingServiceProtocol {
    func getStandings(series: Series) async throws -> Standings
}
