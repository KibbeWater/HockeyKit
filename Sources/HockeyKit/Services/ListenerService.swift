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
    private let url: URL = BroadcasterEndpoint.live.url

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

    public override init() {
        self.maxRetries = 5
        self.baseDelay = 1.0
        self.maxDelay = 60.0
        super.init()
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
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300

        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        task = session?.dataTask(with: url)
        task?.resume()
        isConnected = true
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

    // MARK: - URLSessionDataDelegate Methods

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)

        while let range = buffer.rangeOfNextEvent() {
            let eventData = buffer.subdata(in: range)
            buffer.removeSubrange(range)

            do {
                let event = try JSONDecoder().decode(GameData.self, from: eventData)
                eventSubject.send(event)
                // Reset retry count after a successful event
                currentRetryCount = 0
                currentDelay = baseDelay
            } catch {
                print("Failed to decode event: \(error)")
                errorSubject.send(error)
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
        }
        attemptReconnection()
    }
}

private extension Data {
    /// Finds the range of the next event in the buffer, assuming events are separated by newlines.
    func rangeOfNextEvent() -> Range<Data.Index>? {
        guard let newlineRange = self.range(of: "\n".data(using: .utf8)!) else {
            return nil
        }
        return startIndex..<newlineRange.upperBound
    }
}

