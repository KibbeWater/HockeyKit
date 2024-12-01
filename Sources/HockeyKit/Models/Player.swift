//
//  Player.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 29/11/24.
//

public enum PlayerStatisticKey: String, Codable, Sendable {
    case matches = "GPI"
    case saves = "SVS"
    case savesPercent = "SVSPerc"
    case goalsPerHour = "GAA"
}

public struct Player: Codable, Equatable, Sendable {
    public let uuid: String
    public let age: PlayerAttribute
    public let birthDate: String
    public let careerStats: [PlayerAttribute]
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let position: String
    public let height: PlayerAttribute
    public let jerseyNumber: Int?
    public let seasonStats: [PlayerAttribute]
    public let weight: PlayerAttribute
    public let team: PlayerTeam
    
    public func getStats(for key: PlayerStatisticKey) -> Float? {
        let stats = seasonStats.first(where: { $0.field == key.rawValue })
        return stats?.value
    }
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    public struct PlayerTeam: Codable, Sendable {
        public let name: String
        public let code: String
    }

    public struct PlayerAttribute: Codable, Sendable {
        let value: Float
        let format: String?
        let field: String?
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let _floatVal = try? container.decodeIfPresent(Float.self, forKey: .value)
            let _stringVal = try? container.decodeIfPresent(String.self, forKey: .value)
            
            let ss = _stringVal.map(Float.init)
            self.value = _floatVal ?? (ss ?? 0.0)!
            
            self.format = try container.decodeIfPresent(String.self, forKey: .format)
            self.field = try container.decodeIfPresent(String.self, forKey: .field)
        }
    }
}
