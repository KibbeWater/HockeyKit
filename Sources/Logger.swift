//
//  Logging.swift
//
//
//  Created by KibbeWater on 1/3/24.
//

import Foundation

public class Logging {
    public static var shared = Logging()
    
    private var _messages: [String] = []
    
    public func log(_ msg: String) {
        _messages.append(msg)
        print(msg)
    }
    
    public func getLogs() -> String {
        return _messages.joined(separator: "\n")
    }
}
