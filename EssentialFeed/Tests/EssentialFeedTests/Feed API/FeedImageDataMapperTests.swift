//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 15/09/2023.
//

import Foundation
import XCTest
import EssentialFeed
import TestHelpers

final class FeedImageDataMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [100, 199, 201, 300]
        
        try samples.forEach { statusCode in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(anyData(), from: response(with: statusCode))
            )
        }
    }
    
    func test_map_throwsErrorOnEmptyData() {
        let emptyData = Data()
       
        XCTAssertThrowsError(
            try FeedImageDataMapper.map(emptyData, from: response(with: 200))
        )
    }
    
    func test_map_deliversNonEmptyReceivedDataOn200HTTPResponse() throws {
        let nonEmptyData = Data("non-empty data".utf8)
        
        let result = try FeedImageDataMapper.map(nonEmptyData, from: response(with: 200))
        
        XCTAssertEqual(result, nonEmptyData)
    }
}
