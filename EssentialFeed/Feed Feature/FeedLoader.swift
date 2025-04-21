//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 21/04/25.
//

/// We start with a generic Error, we can start creating our error type with an
/// enum but is too early
enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}


/// We use our completion type, but we don't throw errors for now we deliver it
/// as a closure for now
protocol FeedLoader {
    func loadItems(completion:@escaping(LoadFeedResult)->Void)
}
