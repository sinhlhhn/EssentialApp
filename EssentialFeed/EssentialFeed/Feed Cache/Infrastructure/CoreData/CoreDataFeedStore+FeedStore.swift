//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Sam on 20/09/2023.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(Result(catching: {
                try ManagedCache.deleteCache(in: context)
            }))
        }
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            completion(Result(catching: {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = currentDate
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
            }))
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion(Result(catching: {
                try ManagedCache.find(in: context).map {
                    return CachedFeed($0.localFeed, $0.timestamp)
                }
            }))
        }
    }
}
