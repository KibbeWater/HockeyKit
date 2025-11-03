//
//  EndpointConfiguration.swift
//  HockeyKit
//
//  Configuration for API endpoint base URLs
//

import Foundation

/// Configuration for API endpoint base URLs
public struct EndpointConfiguration: Sendable {
    /// Base URL for the main SHL API
    let baseURL: URL
    
    /// Base URL for live game data
    let liveBaseURL: URL
    
    /// Base URL for broadcaster data
    let broadcasterBaseURL: URL
    
    /// Creates an endpoint configuration with custom base URLs
    /// - Parameters:
    ///   - baseURL: Base URL for the main SHL API. Defaults to "https://www.shl.se/api"
    ///   - liveBaseURL: Base URL for live game data. Defaults to "https://game-data.s8y.se"
    ///   - broadcasterBaseURL: Base URL for broadcaster data. Defaults to "https://game-broadcaster.s8y.se"
    public init(
        baseURL: URL? = nil,
        liveBaseURL: URL? = nil,
        broadcasterBaseURL: URL? = nil
    ) {
        self.baseURL = baseURL ?? URL(string: "https://www.shl.se/api")!
        self.liveBaseURL = liveBaseURL ?? URL(string: "https://game-data.s8y.se")!
        self.broadcasterBaseURL = broadcasterBaseURL ?? URL(string: "https://game-broadcaster.s8y.se")!
    }
    
    /// Default configuration using standard SHL endpoints
    public static let `default` = EndpointConfiguration()
}
