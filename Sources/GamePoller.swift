//
//  GamePoller.swift
//  
//
//  Created by KibbeWater on 12/30/23.
//

import Foundation

public class GamePoller: NSObject, URLSessionDataDelegate {
    private var dataReceivedCallback: ((GameEvent?, Error?) -> Void)?
    private var url: URL
    public let matchId: String?
    
    public init(url: URL, gameId: String? = nil, dataReceivedCallback: ((GameEvent?, Error?) -> Void)?) {
        print("Init GamePoller")
        self.dataReceivedCallback = dataReceivedCallback
        self.url = url
        self.matchId = gameId
        super.init()
        
        // Optional gameId incase we want to get an initial call
        if let _gameId = gameId {
            let matchInfo = MatchInfo()
            
            Task {
                if let callback = dataReceivedCallback {
                    print("GamePoller Pre-fetch game")
                    if let match = try await matchInfo.getMatch(_gameId) {
                        print("Finished GamePoller pre-fetch")
                        print("\(match.gameUuid)")
                        callback(GameEvent(id: -1, game: GameData(gameOverview: match)), nil)
                    }
                }
            }
        }
        
        startRequest()
    }
    
    func startRequest() {
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest)
        dataTask.delegate = self
        dataTask.resume()
    }
    
    func procesRequest(data: String) -> Void {
        var _data = data;
        
        // Data Pre-processing
        _data = _data.trimmingCharacters(in: ["\n", " "])
        
        let dataSplit = _data.split(separator: "\n")
        
        if dataSplit.count >= 2 {
            let idStr = dataSplit[0]
            let dataStr = dataSplit[1]
            
            let id = idStr.replacing("id: ", with: "")
            let data = dataStr.replacing("data: ", with: "")
            
            let decoder = JSONDecoder()
            do {
                let game = try decoder.decode(GameData.self, from: String(data).data(using: .utf8)!)
                dataReceivedCallback?(GameEvent(id: Int(id)!, game: game), nil)
            } catch {
                print("Error")
            }
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive: Data) {
        let resultString = String(data: didReceive, encoding: .utf8)
        procesRequest(data: resultString!)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        dataReceivedCallback?(nil, error)
    }
}
