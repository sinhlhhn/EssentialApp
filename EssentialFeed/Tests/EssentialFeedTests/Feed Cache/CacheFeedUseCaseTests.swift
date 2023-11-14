//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 15/08/2023.
//

import XCTest
import EssentialFeed
import TestHelpers

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError() as NSError
        
        store.completeDeletion(with: deletionError)
        
        try? sut.save(uniqueImageFeed().models)
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessDeletion() {
        let currentDate = Date.init()
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT { currentDate }
        
        try? sut.save(feed.models)
        store.completeSuccessDeletion()
        
        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed, .insert(feed.locals, currentDate)])
    }
    
    func test_save_failsOnDeletionError() {
        let deletionError = anyNSError() as NSError
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError() as NSError
        
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
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectError: NSError?, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
        
        action()
        
        do {
            try sut.save(uniqueImageFeed().models)
        } catch {
            XCTAssertEqual((error as NSError?)?.code, (expectError as NSError?)?.code, file: file, line: line)
        }
    }
}
