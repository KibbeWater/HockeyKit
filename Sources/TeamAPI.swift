//
//  TeamAPI.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 27/9/24.
//

import Foundation

public class TeamAPI: ObservableObject {
    public static let shared = TeamAPI()
    
    @Published var cachedTeams: CacheItem<[SiteTeam]>? = nil
    
    public func getTeams(skipCache: Bool = false) async throws -> [SiteTeam] {
        if skipCache {
            self.cachedTeams = nil
        }
        
        if cachedTeams?.isValid() == true {
            return cachedTeams!.cacheItem
        }
        
        let request = URLRequest(url: URL(string: "\(getBaseURL())/site/settings")!)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(TeamSettingsAPIResponse.self, from: data)
        
        DispatchQueue.main.async {
            self.cachedTeams = .init(response.teamsInSite)
        }
        
        return response.teamsInSite
    }
    
    public func getTeam(_ id: String) async throws -> SiteTeam? {
        let teams = try await getTeams()
        
        return teams.first(where: { $0.id == id })
    }
    
    public func getLineup(_ team: SiteTeam) async throws -> [TeamLineup] {
        let request = URLRequest(url: URL(string: "\(getBaseURL())/sports/players/\(team.id)")!)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode([TeamLineup].self, from: data)
        
        return response
    }
}
