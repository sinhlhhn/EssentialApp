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
    
    func retrieve() {
        receivedMessage.append(.retrieve)
    }
}
