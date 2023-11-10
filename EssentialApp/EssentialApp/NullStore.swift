//
//  NullStore.swift
//  EssentialApp
//
//  Created by Sam on 08/11/2023.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws { }
    
    func retrieve(dataFroURL url: URL) throws -> Data? { return .none }
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
}
