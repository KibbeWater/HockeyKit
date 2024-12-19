//
//  ListenerServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 30/11/24.
//

import Foundation
import Combine

public protocol ListenerServiceProtocol {
    func connect()
    func disconnect()
    
    func requestInitialData(_ gameIds: [String])
    
    func subscribe(_ gameId: String) -> AnyPublisher<GameData, Never>
    func subscribe(_ gameIds: [String]) -> AnyPublisher<GameData, Never>
    func subscribe() -> AnyPublisher<GameData, Never>
    
    func errorPublisher() -> AnyPublisher<Error, Never>
}
