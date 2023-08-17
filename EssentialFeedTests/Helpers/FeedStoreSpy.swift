//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Sam on 17/08/2023.
//

import Foundation
import EssentialFeed

final class FeedStoreSpy: FeedStore {
    var deleteCompletion: [DeletionCompletion] = []
    var insertionCompletion: [InsertionCompletion] = []
    var retrievalCompletion: [RetrievalCompletion] = []
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private (set) var receivedMessage = [ReceivedMessage]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        receivedMessage.append(.deleteCacheFeed)
        deleteCompletion.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteCompletion[index](error)
    }
    
    func completeSuccessDeletion(at index: Int = 0) {
        deleteCompletion[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        receivedMessage.append(.insert(feed, currentDate))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletion[index](error)
    }
    
    func completeSuccessInsertion(at index: Int = 0) {
        insertionCompletion[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletion.append(completion)
        receivedMessage.append(.retrieve)
    }
    
    func completeRetrieve(with error: Error, at index: Int = 0) {
        retrievalCompletion[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletion[index](.empty)
    }
    
    func completeRetrieval(at index: Int = 0, with images: [LocalFeedImage], timestamp: Date) {
        retrievalCompletion[index](.success(images, timestamp))
    }
}
