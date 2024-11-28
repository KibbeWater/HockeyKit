//
//  MatchService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

class MatchService: MatchServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getLatest(completion: @escaping (Result<[Game], any Error>) -> Void) {
        networkManager.request(endpoint: .matchesLatest, completion: completion)
    }
    
    func getSeasonSchedule(_ season: Season, completion: @escaping (Result<[Game], any Error>) -> Void) {
        networkManager.request(endpoint: .matchesSchedule(season, .regular), completion: completion)
    }
}
