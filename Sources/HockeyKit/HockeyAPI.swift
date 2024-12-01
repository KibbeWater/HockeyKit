//
//  HockeyAPI.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

public class HockeyAPI: ObservableObject {
    public let season: SeasonServiceProtocol
    public let match: MatchServiceProtocol
    public let team: TeamServiceProtocol
    public let series: SeriesServiceProtocol
    public let standings: StandingServiceProtocol
    public let listener: ListenerServiceProtocol
    public let player: PlayerServiceProtocol

    public init() {
        let networkManager = NetworkManager()
        
        self.season = SeasonService(networkManager: networkManager)
        self.match = MatchService(networkManager: networkManager)
        self.team = TeamService(networkManager: networkManager)
        self.series = SeriesService(networkManager: networkManager)
        self.standings = StandingService(networkManager: networkManager)
        self.player = PlayerService(networkManager: networkManager)
        self.listener = ListenerService()
    }
    
    public func resetCache() {
        let networkManager = NetworkManager()
        
        SeasonService(networkManager: networkManager).resetCache()
        MatchService(networkManager: networkManager).resetCache()
        TeamService(networkManager: networkManager).resetCache()
        SeriesService(networkManager: networkManager).resetCache()
        StandingService(networkManager: networkManager).resetCache()
        PlayerService(networkManager: networkManager).resetCache()
    }
}
