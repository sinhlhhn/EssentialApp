//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 15/08/2023.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(items: uniqueItems().models) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError() as NSError
        
        sut.save(items: uniqueItems().models) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessDeletion() {
        let currentDate = Date.init()
        let items = uniqueItems()
        let (sut, store) = makeSUT { currentDate }
        
        sut.save(items: items.models) { _ in }
        store.completeSuccessDeletion()
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed, .insert(items.locals, currentDate)])
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
        
        var deletionError = [LocalFeedLoader.SaveResult]()
        sut?.save(items: uniqueItems().models, completion: { receivedError in
            deletionError.append(receivedError)
        })
        
        sut = nil
        
        store.completeDeletion(with: anyError())
        
        XCTAssertTrue(deletionError.isEmpty)
    }
    
    func test_save_doesNotDeliveryInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var insertionError = [LocalFeedLoader.SaveResult]()
        sut?.save(items: uniqueItems().models, completion: { receivedError in
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
        
        let exp = expectation(description: "wait for completion")
        var receivedError: NSError?
        sut.save(items: uniqueItems().models) { error in
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
    
    private func uniqueItems() -> (models: [FeedItem], locals: [LocalFeedItem]) {
        let items = [uniqueItem(), uniqueItem()]
        let locals = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
        return (items, locals)
    }
    
    final class FeedStoreSpy: FeedStore {
        var deleteCompletion: [DeletionCompletion] = []
        var insertionCompletion: [InsertionCompletion] = []
        
        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([LocalFeedItem], Date)
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
        
        func insert(items: [LocalFeedItem], currentDate: Date, completion: @escaping InsertionCompletion) {
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
