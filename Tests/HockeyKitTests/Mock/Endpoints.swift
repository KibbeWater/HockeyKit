//
//  Endpoints.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 8/12/24.
//

import Foundation
@testable import HockeyKit

enum TestEndpoint: Endpoints {
    static let baseURL = URL(string: "https://shl.lrlnet.se/tests")!
    
    case getScenarios
    case scenario(String)
    
    var url: URL {
        switch self {
        case .getScenarios: return Self.baseURL.appendingPathComponent("/scenario")
        case .scenario(let id): return Self.baseURL.appendingPathComponent("/scenario/\(id)")
        }
    }
}
