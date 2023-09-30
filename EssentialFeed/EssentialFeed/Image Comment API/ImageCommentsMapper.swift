//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Sam on 29/09/2023.
//

import Foundation

public struct ImageCommentsMapper {
    
    private struct Root: Decodable {
        private let items: [RemoteImageCommentLoaderItem]
        
        private struct RemoteImageCommentLoaderItem: Decodable {
            let id: UUID
            let message: String
            let created_at: Date
            let author: Author
        }
        
        private struct Author: Decodable {
            let username: String
        }
        
        var comments: [ImageComment] {
            items.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, username: $0.author.username)}
        }
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOK(response),
              let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteImageCommentLoader.Error.invalidData
        }
        
        return root.comments
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
