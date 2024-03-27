//
//  ActivityUpdater.swift
//
//
//  Created by KibbeWater on 3/27/24.
//

import Foundation
import ActivityKit

public class ActivityUpdater {
    public static var shared: ActivityUpdater = ActivityUpdater()
    
    func OverviewToState(_ overview: GameOverview) -> SHLWidgetAttributes.ContentState {
        return SHLWidgetAttributes.ContentState(homeScore: overview.homeGoals, awayScore: overview.awayGoals, period: ActivityPeriod(period: overview.time.period, periodEnd: overview.time.periodEnd ?? Date()))
    }
    
    func OverviewToAttrib(_ overview: GameOverview) -> SHLWidgetAttributes {
        return SHLWidgetAttributes(homeTeam: ActivityTeam(name: overview.homeTeam.teamName, teamCode: overview.homeTeam.teamCode), awayTeam: ActivityTeam(name: overview.awayTeam.teamName, teamCode: overview.awayTeam.teamCode))
    }
    
    public func start(match: GameOverview) throws {
        let attrib = OverviewToAttrib(match)
        let initState = OverviewToState(match)
        
        let activity = try Activity.request(
            attributes: attrib,
            content: .init(state: initState, staleDate: nil),
            pushType: .token
        )
        
        Task {
            for await pushToken in activity.pushTokenUpdates {
                let pushTokenString = pushToken.reduce("") {
                    $0 + String(format: "%02x", $1)
                }
                
                // Send the push token
            }
        }
    }
}
