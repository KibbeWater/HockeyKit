//
//  HockeyAPI.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

public class HockeyAPI {
    private let networkManager: NetworkManagerProtocol
    private let configuration: EndpointConfiguration
    public let season: SeasonServiceProtocol
    public let match: MatchServiceProtocol
    public let team: TeamServiceProtocol
    public let series: SeriesServiceProtocol
    public let standings: StandingServiceProtocol
    public lazy var listener: ListenerServiceProtocol = ListenerService(configuration: configuration)
    public let player: PlayerServiceProtocol

    /// Initialize the HockeyAPI with optional custom endpoint URLs
    /// - Parameters:
    ///   - baseURL: Optional custom base URL for the main SHL API. Defaults to "https://www.shl.se/api"
    ///   - liveBaseURL: Optional custom base URL for live game data. Defaults to "https://game-data.s8y.se"
    ///   - broadcasterBaseURL: Optional custom base URL for broadcaster data. Defaults to "https://game-broadcaster.s8y.se"
    public init(baseURL: URL? = nil, liveBaseURL: URL? = nil, broadcasterBaseURL: URL? = nil) {
        let configuration = EndpointConfiguration(
            baseURL: baseURL,
            liveBaseURL: liveBaseURL,
            broadcasterBaseURL: broadcasterBaseURL
        )
        self.configuration = configuration
        
        let networkManager = NetworkManager.create()
        self.networkManager = networkManager

        self.season = SeasonService(networkManager: networkManager, configuration: configuration)
        self.match = MatchService(networkManager: networkManager, configuration: configuration)
        self.team = TeamService(networkManager: networkManager, configuration: configuration)
        self.series = SeriesService(networkManager: networkManager, configuration: configuration)
        self.standings = StandingService(networkManager: networkManager, configuration: configuration)
        self.player = PlayerService(networkManager: networkManager, configuration: configuration)
    }
}
