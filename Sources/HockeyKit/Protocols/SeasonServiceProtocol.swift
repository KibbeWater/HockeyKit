//
//  SeasonServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

protocol SeasonServiceProtocol {
    func getSeasons(completion: @escaping (Result<[Season], Error>) -> Void)
    func getCurrent(completion: @escaping (Result<Season, Error>) -> Void)
}
