//
//  ErrorResponse.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

enum HockeyAPIError: Error, LocalizedError {
    case networkError
    case decodingError
    case serverError(statusCode: Int)
    case internelError(description: String)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error occurred. Please try again."
        case .decodingError:
            return "Failed to decode the response."
        case .serverError(let statusCode):
            return "Server error with status code \(statusCode)."
        case .internelError(let description):
            return "Internal error: \(description)."
        }
    }
}
