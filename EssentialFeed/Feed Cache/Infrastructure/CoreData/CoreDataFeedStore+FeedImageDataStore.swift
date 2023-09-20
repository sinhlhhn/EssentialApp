//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Sam on 20/09/2023.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataFroURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> ()) {
        completion(.success(.none))
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> ()) {
        completion(.success(()))
    }
}
