//
//  StandingServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

protocol StandingServiceProtocol {
    func getStandings(for season: Season, completion: @escaping (Result<Standings, Error>) -> Void)
}
