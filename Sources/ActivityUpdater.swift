//
//  ActivityUpdater.swift
//
//
//  Created by KibbeWater on 3/27/24.
//

import Foundation
import ActivityKit
import UserNotifications

public class ActivityUpdater {
    public static var shared: ActivityUpdater = ActivityUpdater()
    var deviceUUID = UUID()
    
    func OverviewToState(_ overview: GameOverview) -> SHLWidgetAttributes.ContentState {
        return SHLWidgetAttributes.ContentState(homeScore: overview.homeGoals, awayScore: overview.awayGoals, period: ActivityPeriod(period: overview.time.period, periodEnd: (overview.time.periodEnd ?? Date()).ISO8601Format(), state: ActivityState(rawValue: overview.state.rawValue)!))
    }
    
    func OverviewToAttrib(_ overview: GameOverview) -> SHLWidgetAttributes {
        return SHLWidgetAttributes(id: overview.gameUuid, homeTeam: ActivityTeam(name: overview.homeTeam.teamName, teamCode: overview.homeTeam.teamCode), awayTeam: ActivityTeam(name: overview.awayTeam.teamName, teamCode: overview.awayTeam.teamCode))
    }
    
    @available(iOS 16.2, *)
    public func start(match: GameOverview) throws {
        let attrib = OverviewToAttrib(match)
        let initState = OverviewToState(match)
        
        let activity = try Activity.request(
            attributes: attrib,
            content: .init(state: initState, staleDate: nil),
            pushType: .token
        )
        
        Task {
            let center = UNUserNotificationCenter.current()
            
            do {
                try await center.requestAuthorization(options: [.alert])
            } catch {
                // Handle errors that may occur during requestAuthorization.
            }
        }
        
        Task {
            for await pushToken in activity.pushTokenUpdates {
                let pushTokenString = pushToken.reduce("") {
                    $0 + String(format: "%02x", $1)
                }
                
                // Send the push token
                updatePushToken(match, token: pushTokenString)
            }
        }
    }
    
    func updatePushToken(_ match: GameOverview, token: String) {
        var json: [String: Any] = ["deviceUUID": deviceUUID.uuidString,
                                   "token": token,
                                   "matchId": match.gameUuid]
        
        #if DEBUG
        json["environment"] = "development"
        #endif

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: "https://shl.lrlnet.se/api/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // insert json data to the request
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }

        task.resume()
    }
}
