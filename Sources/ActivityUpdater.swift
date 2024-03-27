//
//  ActivityUpdater.swift
//
//
//  Created by KibbeWater on 3/27/24.
//

import Foundation

public class ActivityUpdater {
    public static var shared: ActivityUpdater = ActivityUpdater()
    
    func OverviewToState(_ overview: GameOverview) -> SHLWidgetAttributes.ContentState {
        return SHLWidgetAttributes.ContentState(homeScore: overview.homeGoals, awayScore: overview.awayGoals, period: ActivityPeriod(period: overview.time.period, periodEnd: overview.time.periodEnd ?? Date()))
    }
    
    public static func start(match: GameOverview) throws {
        
    }
}
