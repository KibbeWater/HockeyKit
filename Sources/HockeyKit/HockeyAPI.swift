//
//  HockeyAPI.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//


public class HockeyAPI {
    let season: SeasonServiceProtocol
    let match: MatchServiceProtocol
    let team: TeamServiceProtocol

    public init() {
        let networkManager = NetworkManager()
        self.season = SeasonService(networkManager: networkManager)
        self.match = MatchService(networkManager: networkManager)
        self.team = TeamService(networkManager: networkManager)
    }
}
