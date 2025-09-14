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
        
        #if DEBUG
        resetCache()
        #else
        removeExired()
        #endif
    }
    
    public func resetCache() {
        season.resetCache()
        match.resetCache()
        team.resetCache()
        series.resetCache()
        standings.resetCache()
        player.resetCache()
    }
    
    public func removeExired() {
        let networkManager = NetworkManager()
        
        try? SeasonService(networkManager: networkManager).getCache().removeExpiredObjects()
        try? MatchService(networkManager: networkManager).getCache().removeExpiredObjects()
        try? TeamService(networkManager: networkManager).getCache().removeExpiredObjects()
        try? SeriesService(networkManager: networkManager).getCache().removeExpiredObjects()
        try? StandingService(networkManager: networkManager).getCache().removeExpiredObjects()
        try? PlayerService(networkManager: networkManager).getCache().removeExpiredObjects()
    }
}
