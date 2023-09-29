//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Sam on 29/09/2023.
//

import Foundation

struct ImageCommentsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedLoaderItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedLoaderItem] {
        guard isOK(response),
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentLoader.Error.invalidData
        }
        
        return root.items
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
