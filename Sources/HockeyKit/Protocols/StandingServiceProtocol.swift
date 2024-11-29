//
//  StandingServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

protocol StandingServiceProtocol {
    func getStandings(series: Series) async throws -> Standings
}
