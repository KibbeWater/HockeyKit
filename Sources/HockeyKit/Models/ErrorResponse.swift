//
//  ErrorResponse.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

enum HockeyAPIError: Error, LocalizedError, Equatable {
    case networkError
    case decodingError
    case notFound
    case gameNotPlayed
    case serverError(statusCode: Int)
    case internalError(description: String)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error occurred. Please try again."
        case .decodingError:
            return "Failed to decode the response."
        case .gameNotPlayed:
            return "Requested game is not yet played."
        case .notFound:
            return "Resource not found."
        case .serverError(let statusCode):
            return "Server error with status code \(statusCode)."
        case .internalError(let description):
            return "Internal error: \(description)."
        }
    }
}
