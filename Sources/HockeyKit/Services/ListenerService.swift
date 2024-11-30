//
//  GamePoller.swift
//  
//
//  Created by KibbeWater on 12/30/23.
//

import Foundation
@preconcurrency import Combine

class ListenerService: NSObject, ListenerServiceProtocol, URLSessionDataDelegate, @unchecked Sendable {
    /// The URL of the EventStream endpoint
    private let url: URL = BroadcasterEndpoint.live.url
    
    /// A subject to multicast events to multiple subscribers
    private let eventSubject = PassthroughSubject<GameData, Never>()
    
    /// Error subject for broadcasting connection errors
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
    
    /// Creates a new EventStream listener
    /// - Parameter url: The URL of the EventStream endpoint
    public init(
        maxRetries: Int = 5,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 60.0
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
    }
    
    /// Starts listening to the EventStream
    public func connect() {
        // Reset retry state
        currentRetryCount = 0
        currentDelay = baseDelay
        
        startEventStreamConnection()
    }
    
    /// Internal method to start or restart the event stream connection
    private func startEventStreamConnection() {
        print("Starting connection")
        // Create a URLSession configuration for event streams
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        
        let session = URLSession(configuration: configuration)
        
        // Create a data task for the event stream
        session.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: GameData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    self.handleConnectionClosure()
                case .failure(let error):
                    self.handleConnectionError(error)
                }
            } receiveValue: { [weak self] event in
                // Reset retry count on successful event
                self?.currentRetryCount = 0
                self?.currentDelay = self?.baseDelay ?? 1.0
                self?.eventSubject.send(event)
            }
            .store(in: &cancellables)
        
        isConnected = true
    }
    
    /// Handles connection closure
    private func handleConnectionClosure() {
        isConnected = false
        print("Event stream finished")
        attemptReconnection()
    }
    
    /// Handles connection errors
    private func handleConnectionError(_ error: Error) {
        isConnected = false
        print("Event stream error: \(error)")
        
        // Broadcast the error to subscribers
        errorSubject.send(error)
        
        attemptReconnection()
    }
    
    /// Attempts to reconnect with exponential backoff
    private func attemptReconnection() {
        guard currentRetryCount < maxRetries else {
            print("Max reconnection attempts reached. Stopping reconnection.")
            return
        }
        
        // Calculate exponential backoff delay
        currentDelay = min(currentDelay * 2, maxDelay)
        currentRetryCount += 1
        
        print("Attempting reconnection in \(currentDelay) seconds. Attempt \(currentRetryCount)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentDelay) { [weak self] in
            self?.connect()
        }
    }
    
    /// Stops the EventStream listener
    public func disconnect() {
        cancellables.removeAll()
        isConnected = false
        currentRetryCount = maxRetries // Prevent reconnection
    }
    
    /// Provides a publisher for GameEvents that other parts of the app can subscribe to
    /// - Returns: A publisher of GameEvents
    public func subscribe() -> AnyPublisher<GameData, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    /// Provides a publisher for connection errors
    /// - Returns: A publisher of Errors
    public func errorPublisher() -> AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }
}
