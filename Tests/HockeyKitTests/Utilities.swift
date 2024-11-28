//
//  Test.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Testing
import HockeyKit

struct DateTime {

    @Test("ISO Date parsing", arguments: [
        {"2024-11-26T18:00:00.000Z", Date(timeInterval: 1732644000000, since: .distantPast)}
    ])
    func doISODateParser(dateString: String, expected: Date) async throws {
        let date = formatTimeFromISO(dateString)
        #expect(date == expected)
    }
    
    @Test("DateTime parsing", arguments: [
        {"2024-09-21 13:15:00", Date(timeInterval: 1726917300000, since: .distantPast)}
    ])
    func doDateTimeParser(dateString: String, expected: Date) async throws {
        let date = formatTimeFromDateTime(dateString)
        #expect(date == expected)
    }
}
