//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Sam on 24/08/2023.
//

@preconcurrency import CoreData

public final class CoreDataFeedStore: FeedImageDataStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public struct ModelNotFound: Error {
        public let modelName: String
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
        }
        
        self.container = try NSPersistentContainer.load(modelName: CoreDataFeedStore.modelName, model: model, url: storeURL)
        self.context = container.newBackgroundContext()
    }
    
    func performAsync(_ action: @escaping @Sendable (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    func performSync<R>(_ action: @Sendable (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        return try context.performAndWait {
            try action(context).get()
        }
    }
    
    private func cleanUpReferencesToPersistentStore() {
        context.performAndWait { [container] in
            let coordinator = container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStore()
    }
}
