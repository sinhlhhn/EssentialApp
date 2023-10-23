//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 17/10/2023.
//

import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let receive = FeedEndpoint.get.url(baseURL: baseURL)
        
        XCTAssertEqual(receive.scheme, "http", "scheme")
        XCTAssertEqual(receive.host, "base-url.com", "host")
        XCTAssertEqual(receive.path, "/v1/feed", "path")
        XCTAssertEqual(receive.query, "limit=10", "query")
    }
}
