//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Sam on 17/08/2023.
//

import Foundation
import EssentialFeed

public final class FeedStoreSpy: FeedStore {
    var deleteResult: Result<Void, Error>?
    var insertionResult: Result<Void, Error>?
    var retrievalResult: Result<CachedFeed?, Error>?
    
    public init() {}
    
    public enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    public private (set) var receivedMessage = [ReceivedMessage]()
    
    public func deleteCacheFeed() throws {
        receivedMessage.append(.deleteCacheFeed)
        try deleteResult?.get()
    }
    
    public func completeDeletion(with error: Error, at index: Int = 0) {
        deleteResult = .failure(error)
    }
    
    public func completeSuccessDeletion(at index: Int = 0) {
        deleteResult = .success(())
    }
    
    public func insert(_ feed: [LocalFeedImage], currentDate: Date) throws {
        receivedMessage.append(.insert(feed, currentDate))
        try insertionResult?.get()
    }
    
    public func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    public func completeSuccessInsertion(at index: Int = 0) {
        insertionResult = .success(())
    }
    
    public func retrieve() throws -> CachedFeed? {
        receivedMessage.append(.retrieve)
        return try retrievalResult?.get()
    }
    
    public func completeRetrieve(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    public func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalResult = .success(.none)
    }
    
    public func completeRetrieval(at index: Int = 0, with images: [LocalFeedImage], timestamp: Date) {
        retrievalResult = .success(.some((images, timestamp)))
    }
}
