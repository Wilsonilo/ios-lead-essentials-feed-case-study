//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 22/04/25.
//

import Foundation

public enum HTTPClientResponse {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPCLient:AnyObject {
    func get(
        from url:URL,
        completion:@escaping (HTTPClientResponse) -> Void
    )
}

class HTTPClient:HTTPCLient {
    
    var requestedURLs: [URL] = []
    
    public func get(
        from: URL,
        completion:@escaping (HTTPClientResponse) -> Void
    ) {
        requestedURLs.append(from)
    }

}
