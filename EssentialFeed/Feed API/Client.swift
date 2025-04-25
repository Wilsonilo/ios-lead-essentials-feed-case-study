//
//  Client.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 22/04/25.
//

import Foundation

public enum HTTPClientResponse {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol Client:AnyObject {
    func get(
        from url:URL,
        completion:@escaping (HTTPClientResponse) -> Void
    )
}
