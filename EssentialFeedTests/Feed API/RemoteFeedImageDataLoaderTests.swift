//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 15/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformAnyRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_performURLRequest() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURL_performURLRequestTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnHTTPClientError() {
        let clientError = NSError(domain: "a client error", code: 1)
        let (sut, client) = makeSUT()
        
        expect(sut, completionWithResult: failure(.connectivity)) {
            client.completion(with: clientError, at: 0)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [100, 199, 201, 300]
        
        samples.enumerated().forEach { index, statusCode in
            expect(sut, completionWithResult: failure(.invalidData)) {
                client.completion(withStatusCode: statusCode, data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnEmptyData() {
        let emptyData = Data()
        let (sut, client) = makeSUT()
        
        expect(sut, completionWithResult: failure(.invalidData)) {
            client.completion(withStatusCode: 200, data: emptyData, at: 0)
        }
    }
    
    func test_loadImageDataFromURL_deliversNonEmptyReceivedDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let data = anyData()
        
        expect(sut, completionWithResult: .success(data)) {
            client.completion(withStatusCode: 200, data: data)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceIsDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { result in
            capturedResults.append(result)
        }
        sut = nil
        client.completion(with: anyError())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_cancelLoadImageDataFromURL_cancelsHTTPClientRequest() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.canceledRequests, [], "Expected no canceled URL request until task is canceled")
        
        task.cancel()
        XCTAssertEqual(client.canceledRequests, [url], "Expected canceled URL request after task is canceled")
        
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancelingTask() {
        let url = anyURL()
        let nonEmptyData = Data("non-empty data".utf8)
        let (sut, client) = makeSUT()
        
        var capturedResult = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: url) { capturedResult.append($0) }
        
        task.cancel()
        
        client.completion(with: anyError())
        client.completion(withStatusCode: 200, data: nonEmptyData)
        client.completion(withStatusCode: 300, data: anyData())
        
        XCTAssertTrue(capturedResult.isEmpty, "Expected no received result after task is canceled got \(capturedResult.count) instead")
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeak(sut)
        trackForMemoryLeak(client)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, completionWithResult expectedResult: FeedImageDataLoader.Result, action: (() -> ()), file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        
        let exp = expectation(description: "wait for completion")
        _ = sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(expectedError.code, receivedError.code, file: file, line: line)
                XCTAssertEqual(expectedError.domain, receivedError.domain, file: file, line: line)
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
