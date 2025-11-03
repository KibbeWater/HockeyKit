//
//  Endpoints.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 8/12/24.
//

import Foundation
@testable import HockeyKit

enum TestEndpoint: Endpoints {
    case getScenarios
    case scenario(String)
    
    func url(using configuration: EndpointConfiguration) -> URL {
        let baseURL = URL(string: "https://shl.lrlnet.se/tests")!
        switch self {
        case .getScenarios: return baseURL.appendingPathComponent("/scenario")
        case .scenario(let id): return baseURL.appendingPathComponent("/scenario/\(id)")
        }
    }
}
