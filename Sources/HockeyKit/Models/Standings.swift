//
//  Standings.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

public struct Standings: Codable, Equatable, Sendable {
    public static func == (lhs: Standings, rhs: Standings) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    private var uuid: String
    public var groupings: [StandingGroup]
    public var leagueStandings: [TeamStanding]
    
    public struct StandingGroup: Codable, Sendable {
        public var Description: String
        public var First: Int
        public var Last: Int
        
        enum CodingKeys: String, CodingKey {
            case Description = "description"
            case First = "first"
            case Last = "last"
        }
    }
    
    public struct TeamStanding: Codable, Sendable {
        public var GP: Int
        public var Diff: Int
        public var Points: Int
        public var Rank: Int
        public var info: TeamStandingInfo
        
        public struct TeamStandingInfo: Codable, Sendable {
            public var code: String?
            public var id: String
            public var teamInfo: TeamInfo
            
            public struct TeamInfo: Codable, Sendable {
                public var clubPageLink: String
                public var siteTeamDisplayCode: String
                public var siteTeamDisplayName: String
                public var teamMedia: String
                public var teamNames: TeamNames
                public var teamOwnerInstanceId: String
                public var teamUuid: String
                
                public struct TeamNames: Codable, Sendable {
                    public var code: String
                    public var codeSite: String?
                    public var full: String
                    public var fullSite: String?
                    public var long: String
                    public var longSite: String?
                    public var short: String
                    public var shortSite: String?
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case code
                case id = "teamId"
                case teamInfo
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Not my proudest moment, provided by ChatGPT
            if let intValue = try? container.decodeIfPresent(Int.self, forKey: .GP) {
                GP = intValue
            } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .GP),
                          let intValue = Int(stringValue) {
                GP = intValue
            } else {
                GP = -1
            }

            if let intValue = try? container.decodeIfPresent(Int.self, forKey: .Diff) {
                Diff = intValue
            } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .Diff),
                          let intValue = Int(stringValue) {
                Diff = intValue
            } else {
                Diff = -1
            }

            if let intValue = try? container.decodeIfPresent(Int.self, forKey: .Points) {
                Points = intValue
            } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .Points),
                          let intValue = Int(stringValue) {
                Points = intValue
            } else {
                Points = -1
            }

            if let intValue = try? container.decodeIfPresent(Int.self, forKey: .Rank) {
                Rank = intValue
            } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .Rank),
                          let intValue = Int(stringValue) {
                Rank = intValue
            } else {
                Rank = -1
            }

            info = try container.decode(TeamStandingInfo.self, forKey: .info)
        }
        
        private enum CodingKeys: String, CodingKey {
            case GP
            case Diff
            case Points
            case Rank
            case info
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = UUID().uuidString
        groupings = try container.decode([StandingGroup].self, forKey: .groupings)
        leagueStandings = try container.decode([TeamStanding].self, forKey: .leagueStandings)
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case groupings
        case leagueStandings
    }
}
