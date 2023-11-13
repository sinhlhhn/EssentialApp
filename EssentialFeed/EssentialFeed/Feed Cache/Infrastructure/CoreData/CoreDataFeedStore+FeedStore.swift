//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Sam on 20/09/2023.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    
    public func deleteCacheFeed() throws {
        try performSync { context in
            Result {
                try ManagedCache.deleteCache(in: context)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], currentDate: Date) throws {
        try performSync { context in
            Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = currentDate
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
            }
        }
    }
    
    public func retrieve() throws -> CachedFeed? {
        try performSync { context in
            Result {
                try ManagedCache.find(in: context).map {
                    return CachedFeed($0.localFeed, $0.timestamp)
                }
            }
        }
    }
}
