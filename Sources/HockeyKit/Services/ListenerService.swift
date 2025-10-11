//
//  ListenerService.swift
//
//
//  Created by KibbeWater on 12/30/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(Combine)
@preconcurrency import Combine
#endif

actor BufferManager {
    private var buffer = Data()
    
    func append(_ data: Data) {
        buffer.append(data)
    }
    
    func removeAll() {
        buffer.removeAll()
    }
    
    // Atomic operation to get and remove the next event
    func getAndRemoveNextEvent() async -> Data? {
        guard let eventRange = buffer.rangeOfNextSSEEvent() else {
            return nil
        }
        
        // Since this is all happening within the actor,
        // we're guaranteed that no other code can modify the buffer
        // between these operations
        let eventData = buffer.subdata(in: eventRange)
        buffer.removeSubrange(eventRange)
        return eventData
    }
    
    // Keep these methods for cases where you really need them,
    // but they should be used carefully
    func removeSubrange(_ range: Range<Data.Index>) {
        guard range.lowerBound >= 0,
              range.upperBound <= buffer.count,
              range.lowerBound <= range.upperBound else {
            print("Warning: Attempted to remove invalid range \(range) from buffer of size \(buffer.count)")
            return
        }
        
        buffer.removeSubrange(range)
    }
    
    func rangeOfNextSSEEvent() -> Range<Data.Index>? {
        buffer.rangeOfNextSSEEvent()
    }
    
    func subdata(in range: Range<Data.Index>) -> Data {
        guard range.lowerBound >= 0,
              range.upperBound <= buffer.count,
              range.lowerBound <= range.upperBound else {
            print("Warning: Attempted to access invalid range \(range) from buffer of size \(buffer.count)")
            return Data()
        }
        
        return buffer.subdata(in: range)
    }
}

class ListenerService: NSObject, ListenerServiceProtocol, URLSessionDataDelegate, @unchecked Sendable {
    private let networkManager: NetworkManager
    
    /// The URL of the EventStream endpoint
    private var url: URL = BroadcasterEndpoint.live.url
    
    /// A subject to multicast events to multiple subscribers
    private let eventSubject = PassthroughSubject<GameData, Never>()
    
    /// A subject for broadcasting connection errors
    private let errorSubject = PassthroughSubject<Error, Never>()
    
    /// Combine cancellables to manage subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Indicates whether the stream is currently active
    #if canImport(Combine)
    @Published private(set) public var isConnected = false
    #else
    private(set) public var isConnected = false
    #endif
    
    /// Buffer manager for thread-safe access to the data buffer
    private let bufferManager = BufferManager()
    
    /// Retain information about latest game data for quick access on new initial connections
    private var latestGameData: Dictionary<String, GameData> = [:]
    
    /// Reconnection configuration
    private let maxRetries: Int
    private let baseDelay: TimeInterval
    private let maxDelay: TimeInterval
    
    /// Current retry state
    private var currentRetryCount = 0
    private var currentDelay: TimeInterval = 1.0
    
    /// Internal properties for URLSession and task management
    private var session: URLSession?
    private var task: URLSessionDataTask?
    private var lastReceivedDataTime: Date = .distantPast
    
    /// Internal properties for testing
    private var _test_shouldReconnectOn200: Bool = true
    private var _test_onlyPublishWhenFinished: Bool = false
    
    public override init() {
        self.maxRetries = 5
        self.baseDelay = 1.0
        self.maxDelay = 60.0
        self.networkManager = NetworkManager()
        super.init()
    }
    
    deinit {
        disconnect()
    }
    
    public func connect() {
        currentRetryCount = 0
        currentDelay = baseDelay
        startEventStreamConnection()
    }
    
    private func startEventStreamConnection() {
        print("Starting connection")
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval.infinity
        configuration.timeoutIntervalForResource = TimeInterval.infinity
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        task = session?.dataTask(with: url)
        task?.resume()
        isConnected = true
        lastReceivedDataTime = Date()
    }
    
    public func disconnect() {
        latestGameData = [:]
        task?.cancel()
        task = nil
        session = nil
        Task {
            await bufferManager.removeAll()
        }
        isConnected = false
        cancellables.removeAll()
        currentRetryCount = maxRetries
    }
    
    func getGameData(_ gameId: String) async throws -> GameData? {
        let data: GameData.GameOverview = try await networkManager.request(endpoint: Endpoint.match(gameId))
        return GameData(gameOverview: data)
    }
    
    func requestCachedData(_ gameId: String) {
        guard let game = latestGameData[gameId] else { return }
        self.eventSubject.send(game)
    }
    
    public func requestInitialData(_ gameIds: [String]) {
        gameIds.forEach { gameId in
            requestCachedData(gameId)
            Task { // Get match information to give an initial burst of data
                if let matchInfo: GameData = try? await getGameData(gameId) {
                    self.eventSubject.send(matchInfo)
                }
            }
        }
    }
    
    public func subscribe(_ gameId: String) -> Publisher<GameData, Never> {
        requestInitialData([gameId])
        return subscribe()
    }
    
    public func subscribe(_ gameIds: [String]) -> Publisher<GameData, Never> {
        requestInitialData(gameIds)
        return subscribe()
    }
    
    public func subscribe() -> Publisher<GameData, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    public func errorPublisher() -> Publisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    private func attemptReconnection() {
        guard currentRetryCount < maxRetries else {
            print("Max reconnection attempts reached. Stopping reconnection.")
            return
        }
        
        currentDelay = min(currentDelay * 2, maxDelay)
        currentRetryCount += 1
        print("Attempting reconnection in \(currentDelay) seconds. Attempt \(currentRetryCount)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentDelay) { [weak self] in
            self?.connect()
        }
    }
    
    private func checkKeepAlive() {
        let timeoutThreshold: TimeInterval = 30 // Adjust as needed
        if Date().timeIntervalSince(lastReceivedDataTime) > timeoutThreshold {
            print("Keep-alive timeout. Reconnecting...")
            disconnect()
            attemptReconnection()
        }
    }
    
    // MARK: - Test functions for internal testing
    
    func _internal_testShouldReconnectOn200(_ shouldReconnect: Bool) {
        self._test_shouldReconnectOn200 = shouldReconnect
    }
    
    func _internal_testSetURL(_ url: URL) {
        self.url = url
    }
    
    func _internal_onlyPublishWhenFinished(_ onlyPublishWhenFinished: Bool) {
        self._test_onlyPublishWhenFinished = onlyPublishWhenFinished
    }
    
    // MARK: - URLSessionDataDelegate Methods
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Task {
            await bufferManager.append(data)
            lastReceivedDataTime = Date()
            
            // Use the new atomic operation instead of separate range/subdata/remove calls
            while let eventData = await bufferManager.getAndRemoveNextEvent() {
                guard let eventString = String(data: eventData, encoding: .utf8) else { continue }
                if let jsonData = extractDataField(from: eventString) {
                    await MainActor.run {
                        do {
                            let gameData = try JSONDecoder().decode(GameData.self, from: jsonData)
                            if !self._test_onlyPublishWhenFinished {
                                self.eventSubject.send(gameData)
                            }
                            self.currentRetryCount = 0
                            self.currentDelay = self.baseDelay
                        } catch {
                            print("Failed to decode GameData: \(error)")
                            self.errorSubject.send(error)
                        }
                    }
                }
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        isConnected = false
        if let error = error {
            print("Stream finished with error: \(error)")
            errorSubject.send(error)
        } else {
            print("Stream finished")
            
            if _test_onlyPublishWhenFinished {
                let team: GameData.GameOverview.TeamData = .init(gameId: 1, place: .away, score: 123, teamId: "123", teamName: "123", teamCode: "123", gameUuid: "123")
                eventSubject.send(GameData.init(gameOverview: .init(homeTeam: team, awayTeam: team, homeGoals: 1, awayGoals: 2, state: .ongoing, gameUuid: "123", time: .init(period: 2, periodTime: "12:30", periodEnd: nil))))
            }
            
            if !_test_shouldReconnectOn200 {
                return
            }
        }
        attemptReconnection()
    }
}

private extension Data {
    func rangeOfNextSSEEvent() -> Range<Data.Index>? {
        guard let range = self.range(of: "\n\n".data(using: .utf8)!) else {
            return nil
        }
        return startIndex..<range.upperBound
    }
}

private func extractDataField(from eventString: String) -> Data? {
    let lines = eventString.split(separator: "\n")
    for line in lines {
        if line.starts(with: "data:") {
            let jsonString = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
            return jsonString.data(using: .utf8)
        }
    }
    return nil
}
