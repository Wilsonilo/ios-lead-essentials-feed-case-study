//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 22/04/25.
//

import Foundation

public final class RemoteFeedLoader {
    
    private let client:Client
    private let url:URL
    
    public init(client: Client, url: URL) {
        self.client = client
        self.url    = url
    }
    
    public func load() {
        client.get(from:url)
    }
}
