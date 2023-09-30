//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Sam on 09/08/2023.
//

import Foundation

public struct FeedItemsMapper {
    
    private struct Root: Decodable {
        private let items: [RemoteFeedLoaderItem]
        
        private struct RemoteFeedLoaderItem: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var images: [FeedImage] {
            items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return root.images
    }
}
