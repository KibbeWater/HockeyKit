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
    
    func getActiveMatch() async {
        guard let _gameId = self.matchId else { return }
        
        let matchInfo = MatchInfo()
        
        do {
            if let callback = dataReceivedCallback {
                print("GamePoller Pre-fetch game")
                if let match = try await matchInfo.getMatch(_gameId) {
                    print("Finished GamePoller pre-fetch")
                    print("\(match.gameUuid)")
                    callback(GameEvent(id: -1, game: GameData(gameOverview: match)), nil)
                }
            }
        } catch _ {
            Logging.shared.log("Failed to fetch active match info")
        }
    }
    
    public init(url: URL, gameId: String? = nil, dataReceivedCallback: ((GameEvent?, Error?) -> Void)?) {
        print("Init GamePoller")
        self.dataReceivedCallback = dataReceivedCallback
        self.url = url
        self.matchId = gameId
        super.init()
        
        // Optional gameId incase we want to get an initial call
        if gameId != nil {
            Task {
                await getActiveMatch()
            }
        }
        
        startRequest()
    }
    
    func startRequest() {
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession(configuration: .ephemeral)
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
            } catch let err {
                startRequest()
                // Restart request
                print(err)
                Logging.shared.log("Request failed, trying again...")
            }
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive: Data) {
        let resultString = String(data: didReceive, encoding: .utf8)
        procesRequest(data: resultString!)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let _err = error {
            print(_err)
        }
        if (error as? URLError)?.code == .timedOut {
            print("Detected timeout error, restarting the request")
            startRequest()
        }
        dataReceivedCallback?(nil, error)
    }
}
