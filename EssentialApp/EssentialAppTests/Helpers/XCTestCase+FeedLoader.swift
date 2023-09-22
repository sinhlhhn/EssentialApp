//
//  XCTestCase+FeedLoader.swift
//  EssentialAppTests
//
//  Created by Sam on 22/09/2023.
//

import XCTest
import EssentialFeed

protocol FeedLoaderTestCase: XCTestCase {}

extension FeedLoaderTestCase {
    func expect(_ sut: FeedLoader, toCompleteWithResult expectedResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError.code, expectedError.code, file: file, line: line)
                XCTAssertEqual(receivedError.domain, expectedError.domain, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}
