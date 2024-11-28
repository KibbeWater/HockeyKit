//
//  File.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Testing
import Foundation
@testable import HockeyKit

@Suite("Utils - Date") struct DateTests {
    @Test("ISO Date string to Date", arguments: [
        ("2024-09-21T13:15:00.000Z", Date(timeIntervalSince1970: 1726928100)),
        ("2024-11-28T18:00:00.000Z", Date(timeIntervalSince1970: 1732820400)),
    ])
    func testISOToDate(date: String, expected: Date) async throws {
        #expect(expected == DateUtils.parseISODate(date))
    }
}
