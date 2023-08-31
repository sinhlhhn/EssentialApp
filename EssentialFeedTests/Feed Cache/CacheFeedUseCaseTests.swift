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
        
        sut.save(uniqueImageFeed().models) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError() as NSError
        
        sut.save(uniqueImageFeed().models) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessDeletion() {
        let currentDate = Date.init()
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT { currentDate }
        
        sut.save(feed.models) { _ in }
        store.completeSuccessDeletion()
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed, .insert(feed.locals, currentDate)])
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
        sut?.save(uniqueImageFeed().models, completion: { receivedError in
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
        sut?.save(uniqueImageFeed().models, completion: { receivedError in
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
        var receivedError: Error?
        sut.save(uniqueImageFeed().models) { result in
            if case let Result.failure(error) = result { receivedError = error }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual((receivedError as NSError?)?.code, (expectError as NSError?)?.code, file: file, line: line)
    }
}
