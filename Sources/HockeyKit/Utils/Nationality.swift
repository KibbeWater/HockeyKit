//
//  Nationality.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//


public enum Nationality: Codable {
    case sweden
    case norway
    case finland
    case usa
    case canada
    case unknown(String)

    // Custom keys for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case sweden = "SE"
        case norway = "NO"
        case finland = "FI"
        case usa = "US"
        case canada = "CA"
        case unknown
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value {
        case "SE":
            self = .sweden
        case "NO":
            self = .norway
        case "FI":
            self = .finland
        case "US":
            self = .usa
        case "CA":
            self = .canada
        default:
            self = .unknown(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .sweden:
            try container.encode("SE")
        case .norway:
            try container.encode("NO")
        case .finland:
            try container.encode("FI")
        case .usa:
            try container.encode("US")
        case .canada:
            try container.encode("CA")
        case .unknown(let value):
            try container.encode(value)
        }
    }
}