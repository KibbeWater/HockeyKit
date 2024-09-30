//
//  PlayerAPI.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 30/9/24.
//

import Foundation

public class PlayerAPI {
    public static let shared = PlayerAPI()
    
    public func getPlayer(id: String) async throws -> Player? {
        guard let url = URL(string: "\(getBaseURL())/sports/player/profile-page?playerUuid=\(id)") else { return nil }
        
        let request = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let player = try decoder.decode(Player.self, from: data)
        
        return player
    }
}
