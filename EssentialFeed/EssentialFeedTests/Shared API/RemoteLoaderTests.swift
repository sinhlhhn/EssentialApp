//
//  RemoteLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 29/09/2023.
//

import XCTest
import EssentialFeed

final class RemoteLoaderTests: XCTestCase {
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
    
    func test_load_deliverErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompletionWith: failure(.connectivity)) {
            let clientError = NSError(domain: "", code: 0)
            client.completion(with: clientError)
        }
    }
    
    func test_map_deliverErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: { _, _ in
            throw anyNSError()
        })
        
        expect(sut, toCompletionWith: failure(.invalidData)) {
            client.completion(withStatusCode: 200, data: anyData())
        }
    }
    
    func test_map_deliverMappedResource() {
        let resource = "a resource"
        let (sut, client) = makeSUT { data, _ in
            String(data: data, encoding: .utf8)!
        }

        expect(sut, toCompletionWith: .success(resource)) {
            client.completion(withStatusCode: 200, data: Data(resource.utf8))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(client: client, url: url) { _, _ in
            "any"
        }
        
        var captureResults = [RemoteLoader<String>.Result]()
        sut?.load { captureResults.append($0) }
        
        sut = nil
        
        client.completion(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(captureResults.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        client: HTTPClient = HTTPClientSpy(),
        url: URL = URL(string: "https://a-url")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (RemoteLoader<String>, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(client: client, url: url, mapper: mapper)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (item: ImageComment, itemJSON: [String: Any]) {
        let item = ImageComment(
            id: id,
            message: message,
            createdAt: createdAt.date,
            username: username)
        let itemJSON: [String : Any] = [
            "id": item.id.uuidString,
            "message": item.message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": item.username
            ]
        ]
        
        return (item, itemJSON)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let json = [
            "items": items
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        return .failure(error)
    }
    
    private func expect(
        _ sut: RemoteLoader<String>,
        toCompletionWith expectResult: RemoteLoader<String>.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
            let expectation = expectation(description: "get data asynchronously")
            sut.load { receiveResult in
                switch (receiveResult, expectResult) {
                case let (.success(receiveItem), .success(expectItem)):
                    XCTAssertEqual(receiveItem, expectItem, file: file, line: line)
                case let (.failure(receiveError), .failure(expectError)):
                    XCTAssertEqual(receiveError, expectError, file: file, line: line)
                default:
                    XCTFail("Expect result \(expectResult) got receive result \(receiveResult) instead", file: file, line: line)
                }
                
                expectation.fulfill()
            }
            
            action()
            
            wait(for: [expectation], timeout: 1)
        }
}


