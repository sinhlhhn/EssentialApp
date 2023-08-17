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
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.store.insert(items: items, currentDate: currentDate(), completion: { [weak self] error in
                    guard self != nil else { return }
                    completion(error)
                })
            }
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(items: [FeedItem], currentDate: Date, completion: @escaping InsertionCompletion)
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
        
        sut.save(items: items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessDeletion() {
        let currentDate = Date.init()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT { currentDate }
        
        sut.save(items: items) { _ in }
        store.completeSuccessDeletion()
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed, .insert(items, currentDate)])
    }
    
    func test_save_failsOnDeletionError() {
        let deletionError = anyError() as NSError
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyError() as NSError
        
        expect(sut, toCompleteWith: insertionError) {
            store.completeSuccessDeletion()
            store.completeInsertion(with: insertionError)
        }
        
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: nil) {
            store.completeSuccessDeletion()
            store.completeSuccessInsertion()
        }
    }
    
    func test_save_doesNotDeliveryDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var deletionError = [Error?]()
        sut?.save(items: [uniqueItem()], completion: { receivedError in
            deletionError.append(receivedError)
        })
        
        sut = nil
        
        store.completeDeletion(with: anyError())
        
        XCTAssertTrue(deletionError.isEmpty)
    }
    
    func test_save_doesNotDeliveryInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var insertionError = [Error?]()
        sut?.save(items: [uniqueItem()], completion: { receivedError in
            insertionError.append(receivedError)
        })
        
        store.completeSuccessDeletion()
        sut = nil
        store.completeInsertion(with: anyError())
        
        XCTAssertTrue(insertionError.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectError: NSError?, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
        let items = [uniqueItem(), uniqueItem()]
        
        let exp = expectation(description: "wait for completion")
        var receivedError: NSError?
        sut.save(items: items) { error in
            receivedError = error as? NSError
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError?.code, expectError?.code, file: file, line: line)
    }
    
    private func anyError() -> Error {
        NSError(domain: "any-error", code: 1)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any des", location: nil, imageURL: URL(string: "https://any-url")!)
    }
    
    final class FeedStoreSpy: FeedStore {
        var deleteCompletion: [DeletionCompletion] = []
        var insertionCompletion: [InsertionCompletion] = []
        
        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([FeedItem], Date)
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
        
        func insert(items: [FeedItem], currentDate: Date, completion: @escaping InsertionCompletion) {
            insertionCompletion.append(completion)
            receivedMessage.append(.insert(items, currentDate))
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletion[index](error)
        }
        
        func completeSuccessInsertion(at index: Int = 0) {
            insertionCompletion[index](nil)
        }
    }
}
