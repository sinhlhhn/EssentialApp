//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sam on 17/08/2023.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*, deprecated)
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*, deprecated)
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*, deprecated)
    func retrieve(completion: @escaping RetrievalCompletion)
    
    
    func deleteCacheFeed() throws
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date) throws
    
    func retrieve() throws -> CachedFeed?
}

public extension FeedStore {
    func deleteCacheFeed() throws {
        let group = DispatchGroup()
        group.enter()
        deleteCacheFeed { _ in
            group.leave()
        }
        
        group.wait()
    }
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date) throws {
        let group = DispatchGroup()
        group.enter()
        insert(feed, currentDate: currentDate) { _ in
            group.leave()
        }
        
        group.wait()
    }
    
    func retrieve() throws -> CachedFeed? {
        let group = DispatchGroup()
        group.enter()
        var result: Result<CachedFeed?, Error>!
        retrieve {
            result = $0
            group.leave()
        }
        
        group.wait()
        return try result.get()
    }
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {}
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {}
    func retrieve(completion: @escaping RetrievalCompletion) {}
}
