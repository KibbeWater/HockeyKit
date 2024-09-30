//
//  TeamLineup.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/9/24.
//

import Foundation

public enum PositionCode: String, Codable {
    case goalkeeper = "GK"
    case defense = "D"
    case forward = "F"
}

public enum PlayerType: String, Codable {
    case athlete = "athlete"
}

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

public struct TeamLineup: Codable {
    public let position: String
    public let positionCode: PositionCode
    public let players: [LineupPlayer]
}

public struct LineupPlayer: Codable {
    public let uuid: String
    public let playerType: PlayerType
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let nationality: Nationality
    public let jerseyNumber: Int?
    public let renderedLatestPortrait: PlayerPortrait?
    
    public static func fakeData() -> LineupPlayer {
        LineupPlayer(
            uuid: "qYD-5ySYjdxTG",
            playerType: .athlete,
            firstName: "John",
            lastName: "Snow",
            fullName: "John Snow",
            nationality: .usa,
            jerseyNumber: 1,
            renderedLatestPortrait: PlayerPortrait(
                url: "https://s8y-cdn-sp-photos.imgix.net/https%3A%2F%2Fcdn.ramses.nu%2Fsports%2Fplayer%2Fportrait%2F1f7b942a-7258-44ee-8c23-f800c8b4c30aFabian%20Wagner.png?ixlib=js-3.8.0&s=5e395ec069b40e295d9d146a66e365fc",
                urlImgOriginalProportion: "https://s8y-cdn-sp-photos.imgix.net/https%3A%2F%2Fcdn.ramses.nu%2Fsports%2Fplayer%2Fportrait%2F1f7b942a-7258-44ee-8c23-f800c8b4c30aFabian%20Wagner.png?ixlib=js-3.8.0&s=5e395ec069b40e295d9d146a66e365fc"
            )
        )
    }
    
    public init(uuid: String, playerType: PlayerType, firstName: String, lastName: String, fullName: String, nationality: Nationality, jerseyNumber: Int?, renderedLatestPortrait: PlayerPortrait? = nil) {
        self.uuid = uuid
        self.playerType = playerType
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.nationality = nationality
        self.jerseyNumber = jerseyNumber
        self.renderedLatestPortrait = renderedLatestPortrait
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.playerType = try container.decode(PlayerType.self, forKey: .playerType)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.fullName = try container.decode(String.self, forKey: .fullName)
        self.nationality = try container.decode(Nationality.self, forKey: .nationality)
        self.renderedLatestPortrait = try container.decodeIfPresent(PlayerPortrait.self, forKey: .renderedLatestPortrait)
        
        let strJersey = try? container.decode(String.self, forKey: .jerseyNumber)
        let intJersey = try? container.decodeIfPresent(Int.self, forKey: .jerseyNumber)
        self.jerseyNumber = strJersey.map(Int.init) ?? intJersey
    }
}

public struct PlayerPortrait: Codable {
    public let url: String
    public let urlImgOriginalProportion: String
}
