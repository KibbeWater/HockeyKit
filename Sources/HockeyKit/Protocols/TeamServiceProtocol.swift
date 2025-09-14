//
//  TeamServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

public protocol TeamServiceProtocol: CacheReset {
    func getTeams() async throws -> [SiteTeam]
    func getTeam(withId id: String) async throws -> SiteTeam
    
    func getLineup(team: SiteTeam) async throws -> [TeamLineup]
}
