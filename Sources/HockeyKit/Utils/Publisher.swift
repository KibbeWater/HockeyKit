//
//  Publisher.swift
//  HockeyKit
//
//  Cross-platform publisher implementation for Linux compatibility
//

import Foundation

#if canImport(Combine)
import Combine

// On Apple platforms, use Combine's types directly
public typealias Publisher<Output, Failure> = AnyPublisher<Output, Failure> where Failure: Error
public typealias AnyCancellable = Combine.AnyCancellable
public typealias PassthroughSubject<Output, Failure> = Combine.PassthroughSubject<Output, Failure> where Failure: Error

#else
// Linux: Custom publisher implementation

/// A protocol for cancelling subscriptions
public protocol Cancellable {
    func cancel()
}

/// A type-erased cancellable object
public final class AnyCancellable: Cancellable, Sendable {
    private let cancelHandler: @Sendable () -> Void

    public init(_ cancelHandler: @escaping @Sendable () -> Void) {
        self.cancelHandler = cancelHandler
    }

    public func cancel() {
        cancelHandler()
    }

    deinit {
        cancel()
    }
}

/// A publisher that delivers elements to subscribers
public final class Publisher<Output, Failure: Error>: Sendable {
    private let sinkHandler: @Sendable (@escaping @Sendable (Output) -> Void, @escaping @Sendable (Failure) -> Void) -> AnyCancellable

    init(sinkHandler: @escaping @Sendable (@escaping @Sendable (Output) -> Void, @escaping @Sendable (Failure) -> Void) -> AnyCancellable) {
        self.sinkHandler = sinkHandler
    }

    /// Attaches a subscriber with closure-based behavior
    public func sink(
        receiveCompletion: @escaping @Sendable (Failure) -> Void = { _ in },
        receiveValue: @escaping @Sendable (Output) -> Void
    ) -> AnyCancellable {
        return sinkHandler(receiveValue, receiveCompletion)
    }
}

/// A subject that broadcasts elements to multiple subscribers
public final class PassthroughSubject<Output, Failure: Error>: Sendable {
    private let lock = NSLock()
    private var subscribers: [UUID: @Sendable (Output) -> Void] = [:]
    private var errorSubscribers: [UUID: @Sendable (Failure) -> Void] = [:]

    public init() {}

    /// Sends a value to all subscribers
    public func send(_ value: Output) {
        lock.lock()
        let currentSubscribers = subscribers
        lock.unlock()

        for subscriber in currentSubscribers.values {
            subscriber(value)
        }
    }

    /// Converts the subject to a type-erased publisher
    public func eraseToAnyPublisher() -> Publisher<Output, Failure> {
        return Publisher { [weak self] receiveValue, receiveCompletion in
            guard let self = self else {
                return AnyCancellable {}
            }

            let id = UUID()

            self.lock.lock()
            self.subscribers[id] = receiveValue
            self.errorSubscribers[id] = receiveCompletion
            self.lock.unlock()

            return AnyCancellable { [weak self] in
                guard let self = self else { return }
                self.lock.lock()
                self.subscribers.removeValue(forKey: id)
                self.errorSubscribers.removeValue(forKey: id)
                self.lock.unlock()
            }
        }
    }
}

// Extension to support Set<AnyCancellable>
extension AnyCancellable: Hashable {
    public static func == (lhs: AnyCancellable, rhs: AnyCancellable) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

#endif
