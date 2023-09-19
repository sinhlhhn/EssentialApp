//
//  LoadImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 19/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataFroURL url: URL)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    private struct LocalFeedImageDataLoaderTask: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        store.retrieve(dataFroURL: url)
        return LocalFeedImageDataLoaderTask()
    }
}

final class LoadImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage.isEmpty, true)
    }
    
    func test_loadImageData_requestStoreDataForURL() {
        let url = anyURL()
        let (sut, store) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.retrieve(dataForURL: url)])
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private class FeedStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
        }
        
        private(set) var receivedMessage = [Message]()
        
        func retrieve(dataFroURL url: URL) {
            receivedMessage.append(.retrieve(dataForURL: url))
        }
    }
}
