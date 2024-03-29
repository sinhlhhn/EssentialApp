//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 17/08/2023.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        _ = try? sut.load()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrieveError = anyNSError()
        
        expect(sut, toCompletionWith: .failure(retrieveError)) {
            store.completeRetrieve(with: retrieveError)
        }
    }
    
    func test_load_deliversNoImageOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompletionWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImageOnNonExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let nonExpiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        expect(sut, toCompletionWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.locals, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnCacheExpiration() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let cacheExpirationTimestamp = fixCurrentDate.minusFeedCacheMaxAge()
        
        expect(sut, toCompletionWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: cacheExpirationTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let expiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        expect(sut, toCompletionWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: expiredTimestamp)
        }
    }
    
    func test_load_HasNotSideEffectOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        _ = try? sut.load()
        
        store.completeRetrieve(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_HasNoSideEffectWhenCacheIsAlreadyEmpty() {
        let (sut, store) = makeSUT()
        
        _ = try? sut.load()
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_HasNoSideEffectOnNonExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let nonExpiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        _ = try? sut.load()
        store.completeRetrieval(with: feed.locals, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_HasNoSideEffectOnCacheExpiration() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let cacheExpirationTimestamp = fixCurrentDate.minusFeedCacheMaxAge()
        
        _ = try? sut.load()
        store.completeRetrieval(with: feed.locals, timestamp: cacheExpirationTimestamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_HasNoSideEffectOnExpiredCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let expiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        _ = try? sut.load()
        store.completeRetrieval(with: feed.locals, timestamp: expiredTimestamp)
        
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
    
    private func expect(_ sut: LocalFeedLoader, toCompletionWith expectedResult: Swift.Result<[FeedImage], Error>, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {

        action()
        
        let receivedResult = Result { try sut.load() }
        switch (receivedResult, expectedResult) {
        case let (.success(receivedImage), .success(expectedImage)):
            XCTAssertEqual(receivedImage, expectedImage, file: file, line: line)
            
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError.code, expectedError.code, file: file, line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
}
