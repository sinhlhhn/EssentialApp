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
        
        expect(sut, toCompletionWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "", code: 0)
            client.completion(with: clientError)
        }
    }
    
    func test_load_deliverOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        [199, 201, 300, 400].enumerated().forEach { index, statusCode in
            expect(sut, toCompletionWith: .failure(.invalidData)) {
                client.completion(statusCode: statusCode, at: index)
            }
        }
    }
    
    func test_load_deliverOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompletionWith: .failure(.invalidData)) {
            let invalidData = Data()
            client.completion(statusCode: 200, data: invalidData)
        }
    }
    
    func test_load_deliverOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompletionWith: .success([])) {
            let emptyJSON = Data("{\"items\": []}".utf8)
            client.completion(statusCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_deliverOn200HTTPResponseWithItemList() {
        let (sut, client) = makeSUT()

        let item1 = FeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "https://a-url.com")!)
        let item1JSON = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://another-url.com")!)
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJSON = [
            "items": [item1JSON, item2JSON]
        ]
        expect(sut, toCompletionWith: .success([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.completion(statusCode: 200, data: json)
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT(client: HTTPClient = HTTPClientSpy(), url: URL = URL(string: "https://a-url")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompletionWith result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
        var captureResults = [RemoteFeedLoader.Result]()
            sut.load { captureResults.append($0) }
        
        action()
        
            XCTAssertEqual(captureResults, [result], file: file, line: line)
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
        
        func completion(statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
