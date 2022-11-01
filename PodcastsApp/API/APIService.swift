//
//  APIService.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 26/10/22.
//

import Foundation
import Alamofire
import FeedKit

class APIService: Service {
    static let shared = APIService()
    private init() { }
    
    private let SEARCH_URL: String = "https://itunes.apple.com/search"
    
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
                else {
                    completion(.success([]))
                }
            }
        }
        .resume()
    }
     */
    
    func searchPodcasts(q: String, completion: @escaping (Result<[Podcast], Error>) -> Void) {
        let parameters: [String: Any] = [
            "media": "podcast",
            "term": q
        ]
        
        AF.request(SEARCH_URL, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .responseDecodable(of: SearchResponse.self, completionHandler: { (response) in
                switch response.result {
                case .success(let searchResponse):
                    completion(.success(searchResponse.results))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            })
    }
    
    func fetchEpisodes(feedUrl: String, completion: @escaping (Result<[Episode], Error>) -> Void) {
        if let url = URL(string: feedUrl) {
            let parser = FeedParser(URL: url)
            parser.parseAsync { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let feed):
                        let episodes: [Episode] = feed.rssFeed?.items ?? []
                        completion(.success(episodes))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
        else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid feed URL"])
            completion(.failure(error))
        }
    }
}
