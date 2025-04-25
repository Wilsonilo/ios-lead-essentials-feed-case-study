//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 22/04/25.
//

import Foundation

class HTTPClient:Client {
    
    var requestedURLs: [URL] = []
    
    public func get(
        from: URL,
        completion:@escaping (HTTPClientResponse) -> Void
    ) {
        requestedURLs.append(from)
    }

}
