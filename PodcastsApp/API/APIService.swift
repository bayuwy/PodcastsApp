//
//  APIService.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 26/10/22.
//

import Foundation

class APIService: Service {
    static let shared = APIService()
    private init() { }
    
    private let BASE_URL: String = "https://itunes.apple.com/search"
    
    /*
    func searchPodcasts(q: String, completion: @escaping (Result<[Podcast], Error>) -> Void) {
        let term = q.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let request = URLRequest(url: URL(string: "\(BASE_URL)?media=podcast&term=\(term)")!)
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else {
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                        completion(.success(response.results))
                    }
                    catch {
                        completion(.failure(error))
                    }
                }
            }
        }
        .resume()
    }
     */
    
    
}
