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
    
    func test_validateCache_doesNotDeleteOnLessThanSevenDaysOldCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let lessThanSevenDaysOldTimestamp = fixCurrentDate.adding(days: -7).adding(seconds: 1)

        sut.validate()

        store.completeRetrieval(with: feed.locals, timestamp: lessThanSevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_validateCache_deletesOnSevenDaysOldCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let sevenDaysOldTimestamp = fixCurrentDate.adding(days: -7)
        
        sut.validate()

        store.completeRetrieval(with: feed.locals, timestamp: sevenDaysOldTimestamp)
        
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
