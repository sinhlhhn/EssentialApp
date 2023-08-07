//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by sinhlh on 04/08/2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-new-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
        XCTAssertEqual(client.requestedURLs.count, 1)
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-new-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
    func test_load_deliverOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "", code: 0)
        
        
        var captureError: RemoteFeedLoader.Error?
        sut.load { error in captureError = error }
        
        XCTAssertEqual(captureError, .connectivity)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(client: HTTPClient = HTTPClientSpy(), url: URL = URL(string: "https://a-url")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        var error: Error?
        
        func get(from url: URL, completion: (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }
}
