//
//  HockeyAPI.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

public class HockeyAPI {
    private let networkManager: NetworkManager
    public let season: SeasonServiceProtocol
    public let match: MatchServiceProtocol
    public let team: TeamServiceProtocol
    public let series: SeriesServiceProtocol
    public let standings: StandingServiceProtocol
    public lazy var listener: ListenerServiceProtocol = ListenerService()
    public let player: PlayerServiceProtocol

    public init() {
        let networkManager = NetworkManager()
        self.networkManager = networkManager

        self.season = SeasonService(networkManager: networkManager)
        self.match = MatchService(networkManager: networkManager)
        self.team = TeamService(networkManager: networkManager)
        self.series = SeriesService(networkManager: networkManager)
        self.standings = StandingService(networkManager: networkManager)
        self.player = PlayerService(networkManager: networkManager)
    }
}
