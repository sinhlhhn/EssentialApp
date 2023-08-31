//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sam on 23/08/2023.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliverErrorOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = delete(from: sut)
        
        XCTAssertNotNil(deletionError)
    }
    
    func assertThatDeleteHasNoSideEffectOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        delete(from: sut)
        
        expect(sut, toRetrieveWithResult: .success(.empty))
    }
}
