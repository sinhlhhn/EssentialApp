//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sam on 17/08/2023.
//

import Foundation

public enum LoadCacheResult {
    case find([LocalFeedImage], Date)
    case failure(Error)
    case empty
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (LoadCacheResult) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
