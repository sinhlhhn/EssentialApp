//
//  CommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Sam on 17/10/2023.
//

import Foundation

public enum CommentsEndpoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appending(path: "/v1/image/\(id)/comments")
        }
    }
}
