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
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
        XCTAssertEqual(client.requestedURLs.count, 1)
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-new-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
    func test_load_deliverOnClientError() {
        let (sut, client) = makeSUT()
        
        var captureErrors = [RemoteFeedLoader.Error]()
        sut.load { captureErrors.append($0) }
        
        let clientError = NSError(domain: "", code: 0)
        client.completion(with: clientError)
        
        XCTAssertEqual(captureErrors, [.connectivity])
    }
    
    func test_load_deliverOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        [199, 201, 300, 400].enumerated().forEach {
            var captureErrors = [RemoteFeedLoader.Error]()
            sut.load {
                captureErrors.append($0)
            }
            client.completion(statusCode: $0.element, at: $0.offset)
            
            XCTAssertEqual(captureErrors, [.invalidData])
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT(client: HTTPClient = HTTPClientSpy(), url: URL = URL(string: "https://a-url")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(requestedURLs: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.requestedURLs }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func completion(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func completion(statusCode: Int, at index: Int = 0) {
            if statusCode != 200 {
                let response = HTTPURLResponse(
                    url: requestedURLs[index],
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil)!
                messages[index].completion(.success(response))
            }
        }
    }
}
