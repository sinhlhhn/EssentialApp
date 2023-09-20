//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Sam on 24/08/2023.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public struct ModelNotFound: Error {
        public let modelName: String
    }
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        guard let model = CoreDataFeedStore.model else {
            throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
        }
        
        self.container = try NSPersistentContainer.load(modelName: CoreDataFeedStore.modelName, model: model, url: storeURL)
        self.context = container.newBackgroundContext()
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result(catching: {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            }))
        }
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result(catching: {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = currentDate
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
            }))
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result(catching: {
                try ManagedCache.find(in: context).map {
                    return CachedFeed($0.localFeed, $0.timestamp)
                }
            }))
        }
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
