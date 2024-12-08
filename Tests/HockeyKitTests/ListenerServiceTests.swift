//
//  ListenerServiceTests.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 8/12/24.
//

import Foundation
import Testing
@testable import HockeyKit

fileprivate struct Scenario: Codable {
    let id: String
    let name: String
    let description: String
}

@Suite("Service - Listener Service")
struct ListenerServiceTests {
    
    func setupService(_ url: URL) throws -> ListenerService {
        let service = ListenerService()
        service._internal_testShouldReconnectOn200(false)
        service._internal_testSetURL(url)
        service._internal_onlyPublishWhenFinished(true)
        return service
    }
    
    @Test("Scenario - Delayed Buffer")
    func delayedBuffer() async throws {
        let id = "delayed-bufer"
        let endpoint = TestEndpoint.scenario(id)
        
        let service = try setupService(endpoint.url)
        
        try await confirmation("Does scenario \"Delayed Buffer\" pass without errors") { fulfilled in
            let cancellable = service.subscribe()
                .sink { event in
                    fulfilled()
                }
            
            service.connect()
            
            let sleepAmount: Double = 15
            try await Task.sleep(nanoseconds: UInt64(sleepAmount * Double(NSEC_PER_SEC)))
            
            cancellable.cancel()
        }
    }
    
    @Test("Scenario - Invalid Data")
    func invalidData() async throws {
        let id = "invalid-data"
        let endpoint = TestEndpoint.scenario(id)
        
        let service = try setupService(endpoint.url)
        
        try await confirmation("Does scenario \"Invalid Data\" pass with only one error", expectedCount: 1) { fulfilled in
            let cancellable = service.errorPublisher()
                .sink { event in
                    fulfilled()
                }
            
            service.connect()
            
            let sleepAmount: Double = 5
            try await Task.sleep(nanoseconds: UInt64(sleepAmount * Double(NSEC_PER_SEC)))
            
            cancellable.cancel()
        }
    }
    
    @Test("Scenario - Invalid Format")
    func invalidFormat() async throws {
        let id = "invalid-format"
        let endpoint = TestEndpoint.scenario(id)
        
        let service = try setupService(endpoint.url)
        service._internal_onlyPublishWhenFinished(false)

        try await confirmation("Does scenario \"Invalid Format\" pass with no errors and no events", expectedCount: 2) { fulfilled in
            let cancellable = service.subscribe()
                .sink { event in
                    fulfilled()
                }
            
            let errorCancellable = service.errorPublisher()
                .sink { error in
                    print("Error: \(error)")
                }
            
            service.connect()
            
            let sleepAmount: Double = 5
            try await Task.sleep(nanoseconds: UInt64(sleepAmount * Double(NSEC_PER_SEC)))
            
            cancellable.cancel()
            errorCancellable.cancel()
        }
    }
}
