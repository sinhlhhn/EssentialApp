//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by sinhlh on 04/08/2023.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url")!)
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class EssentialFeedTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_init_requestDataFromURL() {
        
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
