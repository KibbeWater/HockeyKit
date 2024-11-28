//
//  NetworkManager.swift
//  HockeyKit
//
//  Created by Linus Rönnbäck Larsson on 28/11/24.
//

import Foundation

class NetworkManager {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: endpoint.url)
        // request.httpMethod = endpoint.method

        let task = session.dataTask(with: request) { data, response, error in
            // Handle networking errors
            if let error = error {
                completion(.failure(error))
                return
            }

            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(HockeyAPIError.networkError))
                return
            }

            // Decode data
            guard let data = data else {
                completion(.failure(HockeyAPIError.decodingError))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(HockeyAPIError.decodingError))
            }
        }

        task.resume()
    }
}
