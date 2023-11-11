//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Sam on 17/08/2023.
//

import Foundation
import EssentialFeed

final class FeedStoreSpy: FeedStore {
    var deleteResult: Result<Void, Error>?
    var insertionResult: Result<Void, Error>?
    var retrievalResult: Result<CachedFeed?, Error>?
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private (set) var receivedMessage = [ReceivedMessage]()
    
    func deleteCacheFeed() throws {
        receivedMessage.append(.deleteCacheFeed)
        try deleteResult?.get()
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteResult = .failure(error)
    }
    
    func completeSuccessDeletion(at index: Int = 0) {
        deleteResult = .success(())
    }
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date) throws {
        receivedMessage.append(.insert(feed, currentDate))
        try insertionResult?.get()
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeSuccessInsertion(at index: Int = 0) {
        insertionResult = .success(())
    }
    
    func retrieve() throws -> CachedFeed? {
        receivedMessage.append(.retrieve)
        return try retrievalResult?.get()
    }
    
    func completeRetrieve(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalResult = .success(.none)
    }
    
    func completeRetrieval(at index: Int = 0, with images: [LocalFeedImage], timestamp: Date) {
        retrievalResult = .success(.some((images, timestamp)))
    }
}
