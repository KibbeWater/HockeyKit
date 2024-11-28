//
//  File.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

public protocol MatchServiceProtocol {
    func getLatest(completion: @escaping (Result<[Game], Error>) -> Void)
    func getSeasonSchedule(_ season: Season, completion: @escaping (Result<[Game], Error>) -> Void)
}
