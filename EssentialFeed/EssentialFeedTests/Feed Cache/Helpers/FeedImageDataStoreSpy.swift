//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Sam on 20/09/2023.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(dataForURL: URL)
        case insert(_ data: Data, for: URL)
    }
    
    private var retrievalResult: Result<Data?, Error>?
    private var insertionResult: Result<Void, Error>?
    private(set) var receivedMessage = [Message]()
    
    func retrieve(dataFroURL url: URL) throws -> Data? {
        receivedMessage.append(.retrieve(dataForURL: url))
        return try retrievalResult?.get()
    }
    
    func insert(_ data: Data, for url: URL) throws {
        receivedMessage.append(.insert(data, for: url))
        try insertionResult?.get()
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalResult = .success(data)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
}
