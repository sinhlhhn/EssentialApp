//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 18/08/2023.
//

import XCTest
import EssentialFeed
import TestHelpers

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        store.completeRetrieve(with: anyNSError())
        try? sut.validateCache()
        
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheWhenCacheIsAlreadyEmpty() {
        let (sut, store) = makeSUT()
        
        try? sut.validateCache()
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteOnNonExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let nonExpiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)

        try? sut.validateCache()

        store.completeRetrieval(with: feed.locals, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_validateCache_deletesOnCacheExpiration() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let cacheExpirationTimestamp = fixCurrentDate.minusFeedCacheMaxAge()
        
        store.completeRetrieval(with: feed.locals, timestamp: cacheExpirationTimestamp)
        
        try? sut.validateCache()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_deleteOnExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let expiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)

        store.completeRetrieval(with: feed.locals, timestamp: expiredTimestamp)
        
        try? sut.validateCache()

        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, completionWithResult: .failure(deletionError)) {
            store.completeRetrieve(with: anyNSError())
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_validateCache_failsOnSuccessfulDeletionOfFailedRetrieval() {
        let (sut, store) = makeSUT()

        expect(sut, completionWithResult: .success(())) {
            store.completeRetrieve(with: anyNSError())
            store.completeSuccessDeletion()
        }
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, completionWithResult: .success(())) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let nonExpiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)

        expect(sut, completionWithResult: .success(())) {
            store.completeRetrieval(with: feed.locals, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let expiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let deletionError = anyNSError()
        
        expect(sut, completionWithResult: .failure(deletionError)) {
            store.completeRetrieval(with: feed.locals, timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, completionWithResult: .success(())) {
            store.completeRetrieval(with: feed.locals, timestamp: expiredTimestamp)
            store.completeSuccessDeletion()
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
    
    private func expect(_ sut: LocalFeedLoader, completionWithResult expectedResult: LocalFeedLoader.ValidationResult, action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        action()
        
        let receivedResult = Result { try sut.validateCache() }
        switch (receivedResult, expectedResult) {
        case (.success(()), .success(())):
            break
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError.code, expectedError.code)
            XCTAssertEqual(receivedError.domain, expectedError.domain)
        default:
            XCTFail("Expected \(expectedResult) got \(receivedResult) instead", file: file, line: line)
        }
    }
}
