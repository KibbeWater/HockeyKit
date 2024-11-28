//
//  Date.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

enum DateUtils {
    /// A shared date formatter configured for the `Europe/Stockholm` timezone.
    private static let stockholmDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/Stockholm")
        formatter.formatOptions = [
            .withInternetDateTime, // Full date and time with timezone
            .withFractionalSeconds // Include fractional seconds if available
        ]
        return formatter
    }()

    /// Parses an ISO8601 date string into a `Date` object in the `Europe/Stockholm` timezone.
    ///
    /// - Parameter isoDateString: The ISO8601 date string to parse.
    /// - Returns: A `Date` object if parsing succeeds, or `nil` otherwise.
    static func parseISODate(_ isoDateString: String) -> Date? {
        return stockholmDateFormatter.date(from: isoDateString)
    }

    /// Formats a `Date` object into an ISO8601 string in the `Europe/Stockholm` timezone.
    ///
    /// - Parameter date: The `Date` object to format.
    /// - Returns: A formatted ISO8601 date string.
    static func formatISODate(_ date: Date) -> String {
        return stockholmDateFormatter.string(from: date)
    }
}
