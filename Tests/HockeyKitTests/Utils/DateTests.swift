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
        /*("2024-09-21T13:15:00.000Z", Date(timeIntervalSince1970: 1726928100)),
        ("2024-11-28T18:00:00.000Z", Date(timeIntervalSince1970: 1732820400)),
        ("2024-09-21T13:15:00+0200", Date(timeIntervalSince1970: 1726917300)),
        ("2025-02-20T18:00:00+0100", Date(timeIntervalSince1970: 1740070800)),*/
        ("2024-12-19T18:00:00.000Z", Date(timeIntervalSince1970: 1734631200)),
        ("2025-01-09T18:00:00.000Z", Date(timeIntervalSince1970: 1736445600))
        // ("2025-01-09T18:00:00+0100", Date(timeIntervalSince1970: 1736445600))
    ])
    func testISOToDate(date: String, expected: Date) async throws {
        #expect(expected == DateUtils.parseISODate(date))
    }
}
