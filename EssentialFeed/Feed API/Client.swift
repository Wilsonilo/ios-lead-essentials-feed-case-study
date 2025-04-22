//
//  Client.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 22/04/25.
//

import Foundation

public protocol Client:AnyObject {
    var requestedURL:URL? { get set}
    func get(from:URL)
}
extension Client {
    public func get(from: URL) {
        requestedURL = from
    }
}
