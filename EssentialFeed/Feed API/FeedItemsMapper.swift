//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Sam on 09/08/2023.
//

import Foundation

struct FeedItemsMapper {
    private static let OK_200 = 200
    
    private struct Root: Decodable {
        let items: [RemoteFeedLoaderItem]
        
        var feeds: [FeedItem] {
            items.map { $0.item }
        }
    }

    private struct RemoteFeedLoaderItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feeds)
    }
}
