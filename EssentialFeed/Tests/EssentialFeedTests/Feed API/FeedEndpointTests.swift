//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 17/10/2023.
//

import XCTest
import EssentialFeed
import TestHelpers

final class FeedEndpointTests: XCTestCase {
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let receive = FeedEndpoint.get().url(baseURL: baseURL)
        
        XCTAssertEqual(receive.scheme, "http", "scheme")
        XCTAssertEqual(receive.host, "base-url.com", "host")
        XCTAssertEqual(receive.path, "/v1/feed", "path")
        XCTAssertEqual(receive.query, "limit=10", "query")
    }
    
    func test_feed_endpointURLAfterGivenImage() {
        let baseURL = URL(string: "http://base-url.com")!
        let image = uniqueImage()
        
        let receive = FeedEndpoint.get(after: image).url(baseURL: baseURL)
        
        XCTAssertEqual(receive.scheme, "http", "scheme")
        XCTAssertEqual(receive.host, "base-url.com", "host")
        XCTAssertEqual(receive.path, "/v1/feed", "path")
        XCTAssertEqual(receive.query?.contains("limit=10"), true, "limit query param")
        XCTAssertEqual(receive.query?.contains("after_id=\(image.id)"), true, "after_id query param")
    }
}
