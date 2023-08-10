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
        
        expect(sut, toCompletionWith: failure(.connectivity)) {
            let clientError = NSError(domain: "", code: 0)
            client.completion(with: clientError)
        }
    }
    
    func test_load_deliverOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        [199, 201, 300, 400].enumerated().forEach { index, statusCode in
            expect(sut, toCompletionWith: failure(.invalidData)) {
                let data = makeItemJSON([])
                client.completion(statusCode: statusCode, data: data, at: index)
            }
        }
    }
    
    func test_load_deliverOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompletionWith: failure(.invalidData)) {
            let invalidData = Data()
            client.completion(statusCode: 200, data: invalidData)
        }
    }
    
    func test_load_deliverOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompletionWith: .success([])) {
            let emptyJSON = makeItemJSON([])
            client.completion(statusCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_deliverOn200HTTPResponseWithItemList() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "https://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://another-url.com")!)
        
        expect(sut, toCompletionWith: .success([item1.item, item2.item])) {
            let json = makeItemJSON([item1.itemJSON, item2.itemJSON])
            client.completion(statusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var captureResults = [RemoteFeedLoader.Result]()
        sut?.load { captureResults.append($0) }
        
        sut = nil
        
        client.completion(statusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(captureResults.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(client: HTTPClient = HTTPClientSpy(), url: URL = URL(string: "https://a-url")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath,
                                    line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should has been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (item: FeedItem, itemJSON: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL)
        let itemJSON = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, itemJSON)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let json = [
            "items": items
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompletionWith expectResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
            let expectation = expectation(description: "get data asynchronously")
            sut.load { receiveResult in
                switch (receiveResult, expectResult) {
                case let (.success(receiveItem), .success(expectItem)):
                    XCTAssertEqual(receiveItem, expectItem, file: file, line: line)
                case let (.failure(receiveError as RemoteFeedLoader.Error), .failure(expectError as RemoteFeedLoader.Error)):
                    XCTAssertEqual(receiveError, expectError, file: file, line: line)
                default:
                    XCTFail("Expect result \(expectResult) got receive result \(receiveResult) instead", file: file, line: line)
                }
                
                expectation.fulfill()
            }
            
            action()
            
            wait(for: [expectation], timeout: 1)
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
        
        func completion(statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
