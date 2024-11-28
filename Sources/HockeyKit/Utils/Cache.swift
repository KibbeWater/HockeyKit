//
//  Cache.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation
import Cache

func initCache(forKey key: String) -> Storage<String, String> {
    let diskConfig = DiskConfig(name: key)
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

    let storage = try? Storage<String, String>(
      diskConfig: diskConfig,
      memoryConfig: memoryConfig,
      fileManager: FileManager.default,
      transformer: TransformerFactory.forCodable(ofType: String.self)
    )
    
    return storage!
}
