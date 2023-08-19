//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 18/08/2023.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validate()
        
        store.completeRetrieve(with: anyError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheWhenCacheIsAlreadyEmpty() {
        let (sut, store) = makeSUT()
        
        sut.validate()
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteOnNonExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let nonExpiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)

        sut.validate()

        store.completeRetrieval(with: feed.locals, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_validateCache_deletesOnCacheExpiration() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let cacheExpirationTimestamp = fixCurrentDate.minusFeedCacheMaxAge()
        
        sut.validate()

        store.completeRetrieval(with: feed.locals, timestamp: cacheExpirationTimestamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_deleteOnExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let expiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)

        sut.validate()

        store.completeRetrieval(with: feed.locals, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidateCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validate()
        
        sut = nil
        
        store.completeRetrieve(with: anyError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
        
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
}
