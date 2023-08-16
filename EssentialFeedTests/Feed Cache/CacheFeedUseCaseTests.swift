//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 15/08/2023.
//

import XCTest
import EssentialFeed

final class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [unowned self] error in
            if let error = error {
                completion(error)
            } else {
                self.store.insert(items: items)
            }
        }
    }
}

final class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    var deleteCompletion: [(Error?) -> Void] = []
    var insertions = [FeedItem]()
    
    func deleteCacheFeed(completion: @escaping (Error?) -> Void) {
        deleteCompletion.append(completion)
        deleteCachedFeedCallCount += 1
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteCompletion[index](error)
    }
    
    func completeSuccessDeletion(at index: Int = 0) {
        deleteCompletion[index](nil)
    }
    
    func insert(items: [FeedItem]) {
        insertCallCount += 1
        insertions = items
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items: items) { _ in }
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyError() as NSError
        
        var receivedError: NSError?
        sut.save(items: items) { error in
            receivedError = error as? NSError
        }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
        XCTAssertEqual(receivedError?.code, deletionError.code)
    }
    
    func test_save_requestNewCacheInsertionOnSuccessDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items: items) { _ in }
        store.completeSuccessDeletion()
        
        XCTAssertEqual(store.insertCallCount, 1)
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
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any des", location: nil, imageURL: URL(string: "https://any-url")!)
    }
}
