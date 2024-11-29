//
//  TeamService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

fileprivate struct TeamSettingsAPIResponse: Codable {
    public let instanceId: String
    public let name: String
    public let isLeagueSite: Bool
    public let logo: String?
    
    public let teamsInSite: [SiteTeam]
}

class TeamService: TeamServiceProtocol {
    private let networkManager: NetworkManager
    private let cache = initCache(forKey: "TeamService")
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getTeams() async throws -> [SiteTeam] {
        let teamStorage = cache.transformCodable(ofType: [SiteTeam].self)
        
        if let teams = try? await teamStorage.async.object(forKey: "team-list") {
            return teams
        }
        
        let res: TeamSettingsAPIResponse = try await networkManager.request(endpoint: Endpoint.teams)
        
        try? await teamStorage.async.setObject(res.teamsInSite, forKey: "team-list")
        
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
        return try await networkManager.request(endpoint: Endpoint.teamLineup(team))
    }
}
