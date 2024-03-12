//
//  LeagueStandings.swift
//
//
//  Created by KibbeWater on 12/31/23.
//

import Foundation

public struct StandingResults: Codable, Equatable {
    public static func == (lhs: StandingResults, rhs: StandingResults) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    private var uuid: String
    public var groupings: [StandingGroup]
    public var leagueStandings: [TeamStanding]
    
    public struct StandingGroup: Codable {
        public var Description: String
        public var First: Int
        public var Last: Int
    }
    
    public struct TeamStanding: Codable {
        public var GP: Int
        public var Diff: Int
        public var Points: Int
        public var Rank: Int
        public var info: TeamStandingInfo
        
        public struct TeamStandingInfo: Codable {
            public var code: String?
            public var id: String
            public var teamInfo: TeamInfo
            
            public struct TeamInfo: Codable {
                public var clubPageLink: String
                public var siteTeamDisplayCode: String
                public var siteTeamDisplayName: String
                public var teamMedia: String
                public var teamNames: TeamNames
                public var teamOwnerInstanceId: String
                public var teamUuid: String
                
                public struct TeamNames: Codable {
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

public struct CacheItem<Element: Equatable>: Equatable {
    public var cacheDate: Date = Date()
    public var cacheItem: Element
    
    public init(_ item: Element) {
        self.cacheItem = item
    }
    
    public func isValid(hours: Int? = nil) -> Bool {
        guard hours == nil else {
            return false
        }
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Calculate the time difference in hours
        let hoursSinceCache = calendar.dateComponents([.hour], from: cacheDate, to: currentDate).hour ?? 0
        
        if let specifiedHours = hours {
            return hoursSinceCache <= specifiedHours
        } else {
            return true // No specific hours provided, just check if cache is not nil
        }
    }
}

public enum Leagues: String, CaseIterable {
    case SHL = "qcz-3Nwp4dmpw"
    case SDHL = "qd0-2O1wDzzQm"
}

public class LeagueStandings: ObservableObject, Equatable {
    private var url: String = "https://www.luleahockey.se/api"
    @Published public var standings: Dictionary<Leagues, CacheItem<StandingResults?>> = Dictionary<Leagues, CacheItem<StandingResults?>>()
    private var uuid = UUID().uuidString
    
    public init() {}
    
    public static func == (lhs: LeagueStandings, rhs: LeagueStandings) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public func fetchLeagues(skipCache: Bool = false) {
        Leagues.allCases.forEach { league in
            Task {
                await fetchLeague(league: league, skipCache: skipCache)
            }
        }
    }
    
    public func fetchLeague(league: Leagues, skipCache: Bool = false, clearExisting: Bool = false) async -> StandingResults? {
        if clearExisting {
            self.standings[league] = nil
        }
        
        if !skipCache {
            if self.standings[league]?.isValid(hours: 1) != nil {
                if let _cache = self.standings[league]?.cacheItem {
                    return _cache
                }
            }
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "\(url)/sports/league-standings?ssgtUuid=\(league.rawValue)")!)
        
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(StandingResults.self, from: data)
                
                DispatchQueue.main.async {
                    self.standings[league] = CacheItem<StandingResults?>(result)
                }
                
                return result
            }
        } catch let error {
            print("ERR! fetchLeague")
            print(error)
        }
        
        DispatchQueue.main.async {
            self.standings[league] = CacheItem<StandingResults?>(nil)
        }
        return nil
    }
}
