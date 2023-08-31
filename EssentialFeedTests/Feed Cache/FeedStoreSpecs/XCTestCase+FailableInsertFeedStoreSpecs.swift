//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sam on 23/08/2023.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversFailureOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        let insertionError = insert(feed, timestamp: timestamp, to: sut)
        
        XCTAssertNotNil(insertionError)
    }
    
    func assertThatInsertDeliversHasNoSideEffectOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveWithResult: .success(.empty))
    }
}
