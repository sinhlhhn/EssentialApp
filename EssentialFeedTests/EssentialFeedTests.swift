//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by sinhlh on 04/08/2023.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    var requestedURL: URL?
}

final class EssentialFeedTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
