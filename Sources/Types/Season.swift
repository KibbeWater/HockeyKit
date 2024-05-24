import Foundation

public struct SeasonAPIResponse: Codable, Equatable {
    public var season: [Season]
}

public struct Season: Codable, Equatable {
    public var uuid: String
    public var code: String
    public var names: [Translation]
    public var deleted: Bool
    
    public struct Translation: Codable, Equatable {
        public var language: String
        public var translation: String
    }
}

public struct SeasonSchedule: Codable, Equatable {
    public var gameInfo: [ScheduleGame]
    
    public struct ScheduleGame: Codable, Equatable, Identifiable {
        public var id: String
        public var startDateTime: Date
        public var date: String
        public var time: String
        public var state: ScheduleGameState
        public var overtime: Bool
        public var shootout: Bool
        public var ssgtUuid: String
        
        public var homeTeamInfo: ScheduleTeam
        public var awayTeamInfo: ScheduleTeam
        
        public var venueInfo: ScheduleVenue
        
        public struct ScheduleVenue: Codable, Equatable {
            public var uuid: String
            public var name: String
        }
        
        public struct ScheduleTeam: Codable, Equatable {
            public static func == (lhs: SeasonSchedule.ScheduleGame.ScheduleTeam, rhs: SeasonSchedule.ScheduleGame.ScheduleTeam) -> Bool {
                return lhs.uuid == rhs.uuid
            }
            
            public var status: ScheduleTeamStatus
            public var uuid: String
            public var code: String
            public var score: Int? // If the game is undecided this will become a string instead for whatever fucking reason, good job SHL
            public var names: StandingResults.TeamStanding.TeamStandingInfo.TeamInfo.TeamNames
            
            public enum ScheduleTeamStatus: String, Codable {
                case win = "WIN"
                case lose = "LOSE"
                case undecided = "N/A"
            }
            
            public init(from decoder: any Decoder) throws {
                let container: KeyedDecodingContainer<SeasonSchedule.ScheduleGame.ScheduleTeam.CodingKeys> = try decoder.container(keyedBy: SeasonSchedule.ScheduleGame.ScheduleTeam.CodingKeys.self)
                self.status = try container.decode(SeasonSchedule.ScheduleGame.ScheduleTeam.ScheduleTeamStatus.self, forKey: SeasonSchedule.ScheduleGame.ScheduleTeam.CodingKeys.status)
                self.uuid = try container.decode(String.self, forKey: SeasonSchedule.ScheduleGame.ScheduleTeam.CodingKeys.uuid)
                self.code = try container.decode(String.self, forKey: SeasonSchedule.ScheduleGame.ScheduleTeam.CodingKeys.code)
                self.score = try? container.decode(Int.self, forKey: SeasonSchedule.ScheduleGame.ScheduleTeam.CodingKeys.score)
                self.names = try container.decode(StandingResults.TeamStanding.TeamStandingInfo.TeamInfo.TeamNames.self, forKey: SeasonSchedule.ScheduleGame.ScheduleTeam.CodingKeys.names)
            }
        }
        
        public func toGame() -> Game {
            return Game(
                id: self.id,
                date: self.startDateTime,
                played: self.state == .post,
                overtime: self.overtime,
                shootout: self.shootout,
                ssgtUuid: self.ssgtUuid,
                seriesCode: .SHL,
                venue: self.venueInfo.name,
                homeTeam: Game.Team(
                    name: self.homeTeamInfo.names.long,
                    code: self.homeTeamInfo.names.code,
                    result: self.homeTeamInfo.score ?? 0
                ),
                awayTeam: Game.Team(
                    name: self.awayTeamInfo.names.long,
                    code: self.awayTeamInfo.names.code,
                    result: self.awayTeamInfo.score ?? 0
                )
            )
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<SeasonSchedule.ScheduleGame.CodingKeys> = try decoder.container(keyedBy: SeasonSchedule.ScheduleGame.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.id)
            let dateFormatter = ISO8601DateFormatter()
            let date = try container.decode(String.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.startDateTime)
            self.startDateTime = dateFormatter.date(from: date) ?? Date.distantPast
            self.date = try container.decode(String.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.date)
            self.time = try container.decode(String.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.time)
            self.state = try container.decode(ScheduleGameState.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.state)
            self.overtime = try container.decode(Bool.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.overtime)
            self.shootout = try container.decode(Bool.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.shootout)
            self.ssgtUuid = try container.decode(String.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.ssgtUuid)
            self.homeTeamInfo = try container.decode(SeasonSchedule.ScheduleGame.ScheduleTeam.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.homeTeamInfo)
            self.awayTeamInfo = try container.decode(SeasonSchedule.ScheduleGame.ScheduleTeam.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.awayTeamInfo)
            self.venueInfo = try container.decode(SeasonSchedule.ScheduleGame.ScheduleVenue.self, forKey: SeasonSchedule.ScheduleGame.CodingKeys.venueInfo)
        }
        
        private enum CodingKeys: String, CodingKey {
            case id = "uuid"
            case startDateTime
            case date
            case time
            case state
            case overtime
            case shootout
            case ssgtUuid
            case homeTeamInfo
            case awayTeamInfo
            case venueInfo
        }
    }
}

public enum ScheduleGameState: String, Codable  {
    case pre = "pre-game"
    case post = "post-game"
}
