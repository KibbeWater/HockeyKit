//
//  EndpointConfigurationTests.swift
//  HockeyKit
//
//  Created by Copilot
//

import Testing
@testable import HockeyKit
import Foundation

@Suite("Endpoint Configuration Tests")
struct EndpointConfigurationTests {
    
    @Test("Default Configuration - Uses Default URLs")
    func defaultConfigurationUsesDefaultURLs() {
        let config = EndpointConfiguration.default
        
        #expect(config.baseURL.absoluteString == "https://www.shl.se/api")
        #expect(config.liveBaseURL.absoluteString == "https://game-data.s8y.se")
        #expect(config.broadcasterBaseURL.absoluteString == "https://game-broadcaster.s8y.se")
    }
    
    @Test("Custom Configuration - Uses Custom Base URL")
    func customConfigurationUsesCustomBaseURL() {
        let customURL = URL(string: "https://custom.example.com/api")!
        let config = EndpointConfiguration(baseURL: customURL)
        
        #expect(config.baseURL == customURL)
        #expect(config.liveBaseURL.absoluteString == "https://game-data.s8y.se")
        #expect(config.broadcasterBaseURL.absoluteString == "https://game-broadcaster.s8y.se")
    }
    
    @Test("Custom Configuration - Uses All Custom URLs")
    func customConfigurationUsesAllCustomURLs() {
        let customBase = URL(string: "https://custom-base.example.com")!
        let customLive = URL(string: "https://custom-live.example.com")!
        let customBroadcaster = URL(string: "https://custom-broadcaster.example.com")!
        
        let config = EndpointConfiguration(
            baseURL: customBase,
            liveBaseURL: customLive,
            broadcasterBaseURL: customBroadcaster
        )
        
        #expect(config.baseURL == customBase)
        #expect(config.liveBaseURL == customLive)
        #expect(config.broadcasterBaseURL == customBroadcaster)
    }
    
    @Test("Endpoint Uses Configuration - Main Endpoint")
    func endpointUsesConfiguration() {
        let customURL = URL(string: "https://custom.example.com")!
        let config = EndpointConfiguration(baseURL: customURL)
        
        let endpoint = Endpoint.siteSettings
        let url = endpoint.url(using: config)
        
        #expect(url.absoluteString.hasPrefix(customURL.absoluteString))
    }
    
    @Test("Endpoint Uses Configuration - Live Endpoint")
    func liveEndpointUsesConfiguration() {
        let customURL = URL(string: "https://custom-live.example.com")!
        let config = EndpointConfiguration(liveBaseURL: customURL)
        
        let game = Game(
            id: "test-game-id",
            date: Date(),
            played: true,
            overtime: false,
            shootout: false,
            venue: "Test Arena",
            homeTeam: Team(name: "Home", code: "HOM", result: 3),
            awayTeam: Team(name: "Away", code: "AWY", result: 2)
        )
        let endpoint = LiveEndpoint.playByPlay(game)
        let url = endpoint.url(using: config)
        
        #expect(url.absoluteString.hasPrefix(customURL.absoluteString))
    }
    
    @Test("Endpoint Uses Configuration - Broadcaster Endpoint")
    func broadcasterEndpointUsesConfiguration() {
        let customURL = URL(string: "https://custom-broadcaster.example.com")!
        let config = EndpointConfiguration(broadcasterBaseURL: customURL)
        
        let endpoint = BroadcasterEndpoint.live
        let url = endpoint.url(using: config)
        
        #expect(url.absoluteString.hasPrefix(customURL.absoluteString))
    }
    
    @Test("HockeyAPI Initialization - Default Configuration")
    func hockeyAPIDefaultConfiguration() {
        let _ = HockeyAPI()
        // Verify API initializes without errors
    }
    
    @Test("HockeyAPI Initialization - Custom Base URL")
    func hockeyAPICustomBaseURL() {
        let customURL = URL(string: "https://custom.example.com/api")!
        let _ = HockeyAPI(baseURL: customURL)
        // Verify API initializes without errors with custom URL
    }
    
    @Test("HockeyAPI Initialization - All Custom URLs")
    func hockeyAPIAllCustomURLs() {
        let customBase = URL(string: "https://custom-base.example.com")!
        let customLive = URL(string: "https://custom-live.example.com")!
        let customBroadcaster = URL(string: "https://custom-broadcaster.example.com")!
        
        let _ = HockeyAPI(
            baseURL: customBase,
            liveBaseURL: customLive,
            broadcasterBaseURL: customBroadcaster
        )
        // Verify API initializes without errors with all custom URLs
    }
}
