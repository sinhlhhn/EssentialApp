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
        expect(sut, toRetrieveWithResult: .success(.empty), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveWithResultTwice: .success(.empty))
    }
    
    func assertThatRetrieveDeliversFoundValueOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveWithResult: .success(.find(feed, timestamp)))
    }
    
    func assertThatRetrieveHasNoSideEffectOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveWithResultTwice: .success(.find(feed, timestamp)))
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
        
        expect(sut, toRetrieveWithResult: .success(.find(secondFeed, secondTimestamp)))
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
        
        expect(sut, toRetrieveWithResult: .success(.empty))
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCached(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError)
        expect(sut, toRetrieveWithResult: .success(.empty))
    }
    
    func assertThatStoreSideEffectRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var capturedExpectations = [XCTestExpectation]()
        
        let op1 = expectation(description: "Wait for op1")
        sut.insert(uniqueImageFeed().locals, currentDate: Date()) { _ in
            capturedExpectations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Wait for op2")
        sut.deleteCacheFeed { _ in
            capturedExpectations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Wait for op3")
        sut.insert(uniqueImageFeed().locals, currentDate: Date()) { _ in
            capturedExpectations.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(capturedExpectations, [op1, op2, op3], "Expected side-effects run in serially but operation finished in the wrong oder")
    }
    
    func expect(_ sut: FeedStore, toRetrieveWithResult expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for retrieval")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case let (.success(.find(receivedImages, receivedTimestamp)), .success(.find(expectedImages, expectedTimestamp))):
                XCTAssertEqual(receivedImages, expectedImages)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp)
                
            case (.success(.empty), .success(.empty)), (.failure, .failure): break
                
            default:
                XCTFail("Expected retrieving \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    @discardableResult
    func delete(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for deletion")
        var deletionError: Error?
        sut.deleteCacheFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return deletionError
    }
    
    @discardableResult
    func insert(_ feed: [LocalFeedImage], timestamp: Date, to sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for insertion")
        
        var insertionError: Error?
        sut.insert(feed, currentDate: timestamp) { receivedError in
            insertionError = receivedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return insertionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveWithResultTwice expectedResult: FeedStore.RetrievalResult) {
        expect(sut, toRetrieveWithResult: expectedResult)
        expect(sut, toRetrieveWithResult: expectedResult)
    }
}
