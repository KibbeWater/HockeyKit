//
//  GamePoller.swift
//  
//
//  Created by KibbeWater on 12/30/23.
//

import Foundation

public class GameUpdater: ObservableObject {
    public let gameId: String
    
    @Published public var game: GameOverview? = nil
    
    func getActiveMatch() async {
        let matchInfo = MatchInfo()
        
        do {
            if let match = try await matchInfo.getMatch(gameId) {
                game = match
            }
        } catch _ {
            Logging.shared.log("Failed to fetch active match info")
        }
    }
    
    public func refreshPoller() {
        GamePoller.shared.refreshPoller()
        Task {
            await getActiveMatch()
        }
    }
    
    private func listener(event: GameEvent?, err: Error?) {
        if let _err = err {
            print("Error in gameListener")
            print(_err)
            return
        }
        
        guard gameId == event?.game.gameOverview.gameUuid else {
            return
        }
        
        if let gameOverview = event?.game.gameOverview {
            self.game = gameOverview
        }
    }
    
    public init(gameId: String) {
        self.gameId = gameId
        GamePoller.shared.registerCallback { [weak self] ev, err in
            if let _self = self {
                _self.listener(event: ev, err: err)
            }
        }
        Task {
            await getActiveMatch()
        }
    }
}

class GamePoller: NSObject, URLSessionDataDelegate {
    private let url: URL = URL(string: "https://game-broadcaster.s8y.se/live/game")!
    private var callbacks: [(GameEvent?, Error?) -> Void] = []
    private var task: URLSessionDataTask? = nil
    
    fileprivate static let shared: GamePoller = GamePoller()
    
    public func registerCallback(_ callback: @escaping (GameEvent?, Error?) -> Void) {
        self.callbacks.append(callback)
    }
    
    public func refreshPoller() {
        task?.cancel()
        startRequest()
    }
    
    override init() {
        super.init()
        
        startRequest()
    }
    
    func startRequest() {
        let urlRequest = URLRequest(url: url)
        
        print("Starting new GamePoller session")
        
        let session = URLSession(configuration: .ephemeral)
        let dataTask = session.dataTask(with: urlRequest)
        task = dataTask
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
                guard let game = try? decoder.decode(GameData.self, from: String(data).data(using: .utf8)!) else { return }
                callbacks.forEach { cb in
                    cb(GameEvent(id: Int(id)!, game: game), nil)
                }
                /*refreshPoller()
                print(err)
                Logging.shared.log("Request failed, trying again...")*/
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive: Data) {
        let resultString = String(data: didReceive, encoding: .utf8)
        procesRequest(data: resultString!)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as NSError?, error.code == NSURLErrorCancelled {
            print("Closed connection to live broadcaster")
            return // If it was cancelled we should manage it manually, do not restart
        }
        if (error as? URLError)?.code == .timedOut {
            print("Detected timeout error, restarting the request")
            startRequest()
            return
        }
        if let _err = error {
            print(_err)
        }
        callbacks.forEach { cb in
            cb(nil, error)
        }
    }
}
