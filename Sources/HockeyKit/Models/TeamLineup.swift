//
//  TeamLineup.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//


public struct TeamLineup: Codable {
    public let position: String
    public let positionCode: PositionCode
    public let players: [LineupPlayer]
    
    public enum PositionCode: String, Codable {
        case goalkeeper = "GK"
        case defense = "D"
        case forward = "F"
    }
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
            uuid: "qTN-2OR2VDUpf",
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
    
    public enum PlayerType: String, Codable {
        case athlete = "athlete"
    }
    
    public struct PlayerPortrait: Codable {
        public let url: String
        public let urlImgOriginalProportion: String
    }
}

public struct PlayerPortrait: Codable {
    public let url: String
    public let urlImgOriginalProportion: String
}
