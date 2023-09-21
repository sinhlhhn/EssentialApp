//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by Sam on 24/08/2023.
//

import CoreData

extension NSPersistentContainer {
    
    static func load(modelName name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        try loadError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    convenience init?(name modelName: String, in bundle: Bundle) {
        guard let momd = bundle.url(forResource: modelName, withExtension: "momd") else {
            return nil
        }
        
        self.init(contentsOf: momd)
    }
}
