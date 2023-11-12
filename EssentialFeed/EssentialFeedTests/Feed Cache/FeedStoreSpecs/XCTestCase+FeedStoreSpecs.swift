//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sam on 23/08/2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveWithResult: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveWithResultTwice: .success(.none))
    }
    
    func assertThatRetrieveDeliversFoundValueOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveWithResult: .success(.some((feed, timestamp))))
    }
    
    func assertThatRetrieveHasNoSideEffectOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveWithResultTwice: .success(.some((feed, timestamp))))
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        let insertionError = insert(feed, timestamp: timestamp, to: sut)
        
        XCTAssertNil(insertionError)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        let insertionError = insert(feed, timestamp: timestamp, to: sut)
        
        XCTAssertNil(insertionError)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let firstFeed = uniqueImageFeed().locals
        let firstTimestamp = Date.init()
        
        let secondFeed = uniqueImageFeed().locals
        let secondTimestamp = Date.init()
        
        insert(firstFeed, timestamp: firstTimestamp, to: sut)
        insert(secondFeed, timestamp: secondTimestamp, to: sut)
        
        expect(sut, toRetrieveWithResult: .success(.some((secondFeed, secondTimestamp))))
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(uniqueImageFeed().locals, timestamp: Date(), to: sut)
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError)
    }
    
    func assertThatDeleteHasNoSideEffectOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        delete(from: sut)
        
        expect(sut, toRetrieveWithResult: .success(.none))
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCached(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError)
        expect(sut, toRetrieveWithResult: .success(.none))
    }
    
    func expect(_ sut: FeedStore, toRetrieveWithResult expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let receivedResult = Result { try sut.retrieve() }
        switch (receivedResult, expectedResult) {
        case let (.success(.some((receivedImages, receivedTimestamp))), .success(.some((expectedImages, expectedTimestamp)))):
            XCTAssertEqual(receivedImages, expectedImages)
            XCTAssertEqual(receivedTimestamp, expectedTimestamp)
            
        case (.success(.none), .success(.none)), (.failure, .failure): break
            
        default:
            XCTFail("Expected retrieving \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    @discardableResult
    func delete(from sut: FeedStore) -> Error? {
        
        var deletionError: Error?
        let result = Result { try sut.deleteCacheFeed() }
        switch result {
        case let .failure(receivedError):
            deletionError = receivedError
        default:
            break
        }
        
        return deletionError
    }
    
    @discardableResult
    func insert(_ feed: [LocalFeedImage], timestamp: Date, to sut: FeedStore) -> Error? {
        
        var insertionError: Error?
        let result = Result { try sut.insert(feed, currentDate: timestamp) }
        switch result {
        case let .failure(receivedError):
            insertionError = receivedError
        default:
            break
        }
        
        return insertionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveWithResultTwice expectedResult: FeedStore.RetrievalResult) {
        expect(sut, toRetrieveWithResult: expectedResult)
        expect(sut, toRetrieveWithResult: expectedResult)
    }
}
