//
//  SeasonService.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

fileprivate struct SeasonAPIResponse: Decodable {
    let season: [Season]
}

class SeasonService: SeasonServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getSeasons(completion: @escaping (Result<[Season], any Error>) -> Void) {
        networkManager.request(endpoint: .seasons) { (result: Result<SeasonAPIResponse, any Error>) in
            switch result {
            case .success(let success):
                completion(.success(success.season))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    func getCurrent(completion: @escaping (Result<Season, any Error>) -> Void) {
        getSeasons { result in
            switch result {
            case .success(let success):
                guard let firstSeason = success.first else {
                    return completion(.failure(HockeyAPIError.internelError(description: "Season response was empty")))
                }
                completion(.success(firstSeason))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}
