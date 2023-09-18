//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 15/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (HTTPClient.Result) -> ()) {
        client.get(from: url) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            default:
                break
            }
        }
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformAnyRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.capturedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_performURLRequest() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        let _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.capturedURLs, [url])
    }
    
    func test_loadImageDataFromURL_performURLRequestTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.capturedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let clientError = NSError(domain: "a client error", code: 1)
        let (sut, client) = makeSUT()
        
        expect(sut, completionWithResult: .failure(clientError)) {
            client.completeLoadingImage(with: clientError, at: 0)
        }
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeak(sut)
        trackForMemoryLeak(client)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, completionWithResult expectedResult: HTTPClient.Result, action: (() -> ()), file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        
        let exp = expectation(description: "wait for completion")
        sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(expectedError.code, receivedError.code, file: file, line: line)
                XCTAssertEqual(expectedError.domain, receivedError.domain, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: ((HTTPClient.Result) -> Void))] = []
        
        var capturedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func completeLoadingImage(with error: Error, at index: Int) {
            messages[index].completion(.failure(error))
        }
    }
}
