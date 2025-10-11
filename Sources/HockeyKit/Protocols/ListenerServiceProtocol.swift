//
//  ListenerServiceProtocol.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 30/11/24.
//

import Foundation

#if canImport(Combine)
import Combine
#endif

public protocol ListenerServiceProtocol {
    func connect()
    func disconnect()

    func requestInitialData(_ gameIds: [String])

    func subscribe(_ gameId: String) -> Publisher<GameData, Never>
    func subscribe(_ gameIds: [String]) -> Publisher<GameData, Never>
    func subscribe() -> Publisher<GameData, Never>

    func errorPublisher() -> Publisher<Error, Never>
}
