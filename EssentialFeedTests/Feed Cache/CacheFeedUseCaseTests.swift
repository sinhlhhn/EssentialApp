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
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [unowned self] error in
            if let error = error {
                completion(error)
            } else {
                self.store.insert(items: items, currentDate: currentDate())
            }
        }
    }
}

final class FeedStore {
    var deleteCompletion: [(Error?) -> Void] = []
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([FeedItem], Date)
    }
    
    private (set) var receivedMessage = [ReceivedMessage]()
    
    func deleteCacheFeed(completion: @escaping (Error?) -> Void) {
        receivedMessage.append(.deleteCacheFeed)
        deleteCompletion.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteCompletion[index](error)
    }
    
    func completeSuccessDeletion(at index: Int = 0) {
        deleteCompletion[index](nil)
    }
    
    func insert(items: [FeedItem], currentDate: Date) {
        receivedMessage.append(.insert(items, currentDate))
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_save_requestCacheDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items: items) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
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
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
        XCTAssertEqual(receivedError?.code, deletionError.code)
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessDeletion() {
        let currentDate = Date.init()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT { currentDate }
        
        sut.save(items: items) { _ in }
        store.completeSuccessDeletion()
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed, .insert(items, currentDate)])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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
