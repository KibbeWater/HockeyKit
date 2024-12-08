//
//  ListenerService.swift
//
//
//  Created by KibbeWater on 12/30/23.
//

import Foundation
@preconcurrency import Combine

class ListenerService: NSObject, ListenerServiceProtocol, URLSessionDataDelegate, @unchecked Sendable {
    /// The URL of the EventStream endpoint
    private var url: URL = BroadcasterEndpoint.live.url
    
    /// A subject to multicast events to multiple subscribers
    private let eventSubject = PassthroughSubject<GameData, Never>()
    
    /// A subject for broadcasting connection errors
    private let errorSubject = PassthroughSubject<Error, Never>()
    
    /// Combine cancellables to manage subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Indicates whether the stream is currently active
    @Published private(set) public var isConnected = false
    
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
    private var buffer = Data()
    private var lastReceivedDataTime: Date = .distantPast
    
    /// Internal properties for testing
    private var _test_shouldReconnectOn200: Bool = true
    private var _test_onlyPublishWhenFinished: Bool = false
    
    public override init() {
        self.maxRetries = 5
        self.baseDelay = 1.0
        self.maxDelay = 60.0
        super.init()
    }
    
    deinit {
        disconnect()
    }
    
    public func connect() {
        // Reset retry state
        currentRetryCount = 0
        currentDelay = baseDelay
        
        startEventStreamConnection()
    }
    
    private func startEventStreamConnection() {
        print("Starting connection")
        
        // Create a URLSession with this class as its delegate
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval.infinity // Prevent request timeout
        configuration.timeoutIntervalForResource = TimeInterval.infinity // Prevent resource timeout
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        task = session?.dataTask(with: url)
        task?.resume()
        isConnected = true
        lastReceivedDataTime = Date()
    }
    
    public func disconnect() {
        task?.cancel()
        task = nil
        session = nil
        buffer.removeAll()
        isConnected = false
        cancellables.removeAll()
        currentRetryCount = maxRetries // Prevent reconnection
    }
    
    public func subscribe() -> AnyPublisher<GameData, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    public func errorPublisher() -> AnyPublisher<Error, Never> {
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
        buffer.append(data)
        lastReceivedDataTime = Date() // Update the last received data timestamp
        while let eventRange = buffer.rangeOfNextSSEEvent() {
            let eventData = buffer.subdata(in: eventRange)
            buffer.removeSubrange(eventRange)
            
            guard let eventString = String(data: eventData, encoding: .utf8) else { continue }
            if let jsonData = extractDataField(from: eventString) {
                DispatchQueue.main.async {
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
    /// Finds the range of the next SSE event in the buffer.
    /// SSE events are separated by double newlines (`\n\n`).
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

