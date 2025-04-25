//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 22/04/25.
//

import Foundation

public final class RemoteFeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity, invalidData
    }
    
    public enum Result:Equatable {
        case success([FeedItem]), failure(Error)
    }
    
    private let client:Client
    private let url:URL
    
    public init(client: Client, url: URL) {
        self.client = client
        self.url    = url
    }
    
    public func load (completion:@escaping (Result)-> Void) {
        client.get(from: url) {[weak self] response in
            guard self != nil else { return }
            switch response {
            case .success(let data,  let response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure(_):
                completion(.failure(.connectivity))
            }
            
        }
    }
    
}



