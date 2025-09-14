//
//  StandingServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

public protocol StandingServiceProtocol: CacheReset {
    func getStandings(ssgtUuid: String) async throws -> Standings
}
