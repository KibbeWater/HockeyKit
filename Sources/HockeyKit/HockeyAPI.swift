//
//  HockeyAPI.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

public class HockeyAPI: ObservableObject {
    let season: SeasonServiceProtocol
    let match: MatchServiceProtocol
    let team: TeamServiceProtocol
    let series: SeriesServiceProtocol
    let standings: StandingServiceProtocol

    public init() {
        let networkManager = NetworkManager()
        
        self.season = SeasonService(networkManager: networkManager)
        self.match = MatchService(networkManager: networkManager)
        self.team = TeamService(networkManager: networkManager)
        self.series = SeriesService(networkManager: networkManager)
        self.standings = StandingService(networkManager: networkManager)
    }
}
