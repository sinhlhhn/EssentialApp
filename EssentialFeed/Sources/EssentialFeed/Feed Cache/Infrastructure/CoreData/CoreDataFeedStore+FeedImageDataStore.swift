//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Sam on 20/09/2023.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func retrieve(dataFroURL url: URL) throws -> Data? {
        try performSync { context in
            Result {
                return try ManagedFeedImage.data(with: url, in: context)
            }
        }
    }
    
    public func insert(_ data: Data, for url: URL) throws {
        try performSync { context in
            Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            }
        }
    }
}
