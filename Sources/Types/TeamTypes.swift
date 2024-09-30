//
//  TeamTypes.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 27/9/24.
//

import Foundation

public struct TeamSettingsAPIResponse: Codable {
    public let instanceId: String
    public let name: String
    public let isLeagueSite: Bool
    public let logo: String?
    
    public let teamsInSite: [SiteTeam]
}

public struct LocalizedTeamNames: Codable, Hashable {
    public let code: String
    public let short: String?
    public let long: String?
    public let full: String?
    public let codeSite: String?
    public let shortSite: String?
    public let longSite: String?
    public let fullSite: String?
}

public struct SiteTeam: Identifiable, Equatable, Hashable, Codable {
    public static func == (lhs: SiteTeam, rhs: SiteTeam) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(id: String, name: String, names: LocalizedTeamNames, teamInfo: SiteTeamInfo, icon: String?) {
        self.id = id
        self.name = name
        self.names = names
        self.teamInfo = teamInfo
        self.icon = icon
    }
    
    public let id: String
    public let name: String
    public let names: LocalizedTeamNames
    public let teamInfo: SiteTeamInfo
    public let icon: String?
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        names = try container.decode(LocalizedTeamNames.self, forKey: .names)
        teamInfo = try container.decode(SiteTeamInfo.self, forKey: .teamInfo)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case names
        case teamInfo
        case icon
    }
    
    public static func fakeData() -> Self {
        return .init(
            id: "41c4-41c4BiYZU",
            name: "Random Team",
            names: LocalizedTeamNames(
                code: "LHF",
                short: "LHF",
                long: "Luleå Hockey",
                full: "Luleå Hockey",
                codeSite: "LHF",
                shortSite: "Luleå Hockey",
                longSite: "Luleå Hockey",
                fullSite: "Luleå Hockey"
            ),
            teamInfo: SiteTeamInfo(
                founded: 2024,
                golds: 2,
                goldYears: [2024],
                finals: 3,
                finalYears: [2025],
                retiredNumbers: [
                    "Hello",
                    "World"
                ]
            ),
            icon: "random icon"
        )
    }
}

func parseGolds(_ str: String) -> (Int?, [Int]?)? {
    let pattern = #"(\d+)\*?\s*\(([\d,\s]+)\)"#
    let regex = try? NSRegularExpression(pattern: pattern)
    let range = NSRange(str.startIndex..<str.endIndex, in: str)
    
    if let match = regex?.firstMatch(in: str, options: [], range: range) {
        // Extract the count
        let count = Range(match.range(at: 1), in: str).flatMap { Int(str[$0]) }
        
        // Extract the years string from the match and split it into individual years
        if let yearsRange = Range(match.range(at: 2), in: str) {
            let yearsString = String(str[yearsRange])
            let years = yearsString.split(separator: ",").compactMap {
                Int($0.trimmingCharacters(in: .whitespaces))
            }
            return (count, years)
        }
    }
    
    return nil
}

public struct SiteTeamInfo: Codable, Hashable {
    public let founded: Int?
    public let golds: Int?
    public let goldYears: [Int]?
    public let finals: Int?
    public let finalYears: [Int]?
    public let retiredNumbers: [String]?
    
    init(founded: Int? = nil, golds: Int? = nil, goldYears: [Int]? = nil, finals: Int? = nil, finalYears: [Int]? = nil, retiredNumbers: [String]? = nil) {
        self.founded = founded
        self.golds = golds
        self.goldYears = goldYears
        self.finals = finals
        self.finalYears = finalYears
        self.retiredNumbers = retiredNumbers
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let foundedStr = try container.decodeIfPresent(String.self, forKey: .founded)
        self.founded = Int(foundedStr ?? "1990")
        
        if let _golds = try container.decodeIfPresent(String.self, forKey: .golds) {
            let parsedGolds = parseGolds(_golds)
            self.golds = parsedGolds?.0
            self.goldYears = parsedGolds?.1
        } else {
            self.golds = nil
            self.goldYears = nil
        }
        
        if let _finals = try container.decodeIfPresent(String.self, forKey: .finals) {
            let parsedFinals = parseGolds(_finals)
            self.finals = parsedFinals?.0
            self.finalYears = parsedFinals?.1
        } else {
            self.finals = nil
            self.finalYears = nil
        }
        
        if let _retiredNumbers = try container.decodeIfPresent(String.self, forKey: .retiredNumbers) {
            self.retiredNumbers = _retiredNumbers.split(separator: "").map(String.init)
        } else {
            self.retiredNumbers = nil
        }
        
    }
}
