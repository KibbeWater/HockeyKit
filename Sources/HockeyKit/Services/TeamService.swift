//
//  TeamService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

fileprivate struct TeamSettingsAPIResponse: Codable {
    public let instanceId: String
    public let name: String
    public let isLeagueSite: Bool
    public let logo: String?
    
    public let teamsInSite: [SiteTeam]
}

class TeamService: TeamServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    private let configuration: EndpointConfiguration

    init(networkManager: NetworkManagerProtocol, configuration: EndpointConfiguration = .default) {
        self.networkManager = networkManager
        self.configuration = configuration
    }
    
    func getTeams() async throws -> [SiteTeam] {
        let res: TeamSettingsAPIResponse = try await networkManager.request(endpoint: Endpoint.teams, configuration: configuration)
        
        return res.teamsInSite
    }
    
    func getTeam(withId id: String) async throws -> SiteTeam {
        let teams = try await getTeams()
        
        guard let team = teams.first(where: { $0.id == id }) else {
            throw HockeyAPIError.notFound
        }
        return team
    }
    
    func getLineup(team: SiteTeam) async throws -> [TeamLineup] {
        return try await networkManager.request(endpoint: Endpoint.teamLineup(team), configuration: configuration)
    }
}
