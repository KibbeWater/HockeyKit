//
//  Utilities.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 27/9/24.
//

import Foundation

func _formatDate(_ date: Date) -> Date? {
    let calendar = Calendar.current
    let stockholmTimeZone = TimeZone(identifier: "Europe/Stockholm")!
    
    if let stockholmDate = calendar.date(byAdding: .second, value: stockholmTimeZone.secondsFromGMT(for: date), to: date) {
        return stockholmDate
    }
    
    return nil
}

// Normalize dates to Europe/Stockholm time, I'm sure this can be improved but it works
func formatTimeFromDate(_ date: String, formatter: DateFormatter? = nil) -> Date? {
    let dateFormatter = formatter ?? DateFormatter()
    dateFormatter.timeZone = .gmt
    
    guard let _date = dateFormatter.date(from: date) else { return nil }
    
    if let formattedDate = _formatDate(_date) {
        return formattedDate
    }
    
    return nil
}

// Normalize dates to Europe/Stockholm time, I'm sure this can be improved but it works
func formatTimeFromISO(_ date: String) -> Date? {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.timeZone = .gmt
    
    guard let _date = dateFormatter.date(from: date) else { return nil }
    
    if let formattedDate = _formatDate(_date) {
        return formattedDate
    }
    
    return nil
}
