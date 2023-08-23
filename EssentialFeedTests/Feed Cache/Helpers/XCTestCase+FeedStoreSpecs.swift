//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sam on 23/08/2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func expect(_ sut: FeedStore, toRetrieveWithResult expectedResult: LoadCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for retrieval")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case let (.find(receivedImages, receivedTimestamp), .find(expectedImages, expectedTimestamp)):
                XCTAssertEqual(receivedImages, expectedImages)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp)
                
            case (.empty, .empty), (.failure, .failure): break
                
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
    
    func expect(_ sut: FeedStore, toRetrieveWithResultTwice expectedResult: LoadCacheResult) {
        expect(sut, toRetrieveWithResult: expectedResult)
        expect(sut, toRetrieveWithResult: expectedResult)
    }
}
