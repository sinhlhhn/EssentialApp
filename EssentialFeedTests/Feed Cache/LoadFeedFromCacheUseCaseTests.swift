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
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrieveError = anyError()
        
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
    
    func test_load_deliversCachedImageOnLessThanSevenDaysOldCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let lessThanSevenDaysOldTimestamp = fixCurrentDate.adding(days: -7).adding(seconds: 1)
        
        expect(sut, toCompletionWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.locals, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let sevenDaysOldTimestamp = fixCurrentDate.adding(days: -7)
        
        expect(sut, toCompletionWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: sevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let moreThanSevenDaysOldTimestamp = fixCurrentDate.adding(days: -7).adding(seconds: -1)
        
        expect(sut, toCompletionWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: moreThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetrieve(with: anyError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
    }
    
    func test_load_doesNotDeleteCacheWhenCacheIsAlreadyEmpty() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_doesNotDeleteLessThanSevenDaysOldCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let lessThanSevenDaysOldTimestamp = fixCurrentDate.adding(days: -7).adding(seconds: 1)
        
        sut.load { _ in
            
        }
        store.completeRetrieval(with: feed.locals, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_deletesSevenDaysOldCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let sevenDaysOldTimestamp = fixCurrentDate.adding(days: -7)
        
        sut.load { _ in
            
        }
        store.completeRetrieval(with: feed.locals, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
    }
    
    func test_load_deletesMoreThanSevenDaysOldCache() {
        let fixCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        let feed = uniqueImageFeed()
        let moreThanSevenDaysOldTimestamp = fixCurrentDate.adding(days: -7).adding(seconds: -1)
        
        sut.load { _ in
            
        }
        store.completeRetrieval(with: feed.locals, timestamp: moreThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompletionWith expectedResult: LoadFeedResult, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "wait for complition")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImage), .success(expectedImage)):
                XCTAssertEqual(receivedImage, expectedImage, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError.code, expectedError.code, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1)
    }
    
    private func anyError() -> NSError {
        NSError(domain: "any-error", code: 1)
    }
    
    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: "any des", location: nil, url: URL(string: "https://any-url")!)
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        let locals = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
        return (feed, locals)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
