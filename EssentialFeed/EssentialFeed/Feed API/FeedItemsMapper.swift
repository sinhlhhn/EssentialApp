//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Sam on 09/08/2023.
//

import Foundation

struct FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedLoaderItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedLoaderItem] {
        guard response.isOK,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
