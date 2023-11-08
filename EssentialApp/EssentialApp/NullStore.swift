//
//  NullStore.swift
//  EssentialApp
//
//  Created by Sam on 08/11/2023.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func retrieve(dataFroURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> ()) {
        completion(.success(.none))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> ()) {
        completion(.success(()))
    }
}
