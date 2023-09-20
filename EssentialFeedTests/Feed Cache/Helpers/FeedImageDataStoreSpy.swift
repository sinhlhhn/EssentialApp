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
    
    private var completions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private(set) var receivedMessage = [Message]()
    
    func retrieve(dataFroURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> ()) {
        receivedMessage.append(.retrieve(dataForURL: url))
        completions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> ()) {
        receivedMessage.append(.insert(data, for: url))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        completions[index](.success(data))
    }
}
