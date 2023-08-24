//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Sam on 24/08/2023.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
