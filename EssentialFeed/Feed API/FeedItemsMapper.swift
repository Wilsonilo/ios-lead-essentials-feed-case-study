//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 25/04/25.
//


import Foundation

internal final class FeedItemsMapper {
    
    private struct RootElement:Decodable{
        let items:[Item]
        var feed:[FeedItem] {
            items.map({$0.item })
        }
    }

    private struct Item:Decodable {
        let id:UUID
        let description:String?
        let location:String?
        let image:URL
        
        var item:FeedItem {
            FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }
    
    private static var OK_200:Int { return 200 }
    
    internal static func map(_ data:Data, from response:HTTPURLResponse)-> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder()
                  .decode(RootElement.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)

    }
}
