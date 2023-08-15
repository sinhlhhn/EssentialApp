//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 15/08/2023.
//

import XCTest

final class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(completion: @escaping (Error) -> Void) {
        store.deleteCacheFeed { error in
            completion(error)
        }
    }
}

final class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    var deleteCompletion: [(Error) -> Void] = []
    
    func deleteCacheFeed(completion: @escaping (Error) -> Void) {
        deleteCompletion.append(completion)
        deleteCachedFeedCallCount += 1
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteCompletion[index](error)
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save { _ in }
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError() as NSError
        
        var receivedError: NSError?
        sut.save { error in
            receivedError = error as NSError
        }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
        XCTAssertEqual(receivedError?.code, deletionError.code)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyError() -> Error {
        NSError(domain: "any-error", code: 1)
    }
}
