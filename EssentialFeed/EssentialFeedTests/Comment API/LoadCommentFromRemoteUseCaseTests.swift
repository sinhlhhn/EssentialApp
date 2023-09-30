//
//  LoadCommentFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 29/09/2023.
//

import XCTest
import EssentialFeed

final class LoadCommentFromRemoteUseCaseTests: XCTestCase {
    func test_load_deliverErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        
        [199, 300, 400].enumerated().forEach { index, statusCode in
            expect(sut, toCompletionWith: failure(.invalidData)) {
                let data = makeItemJSON([])
                client.completion(withStatusCode: statusCode, data: data, at: index)
            }
        }
    }
    
    func test_load_deliverErrorOn2xxHTTPResponseWithInvalidData() {
        let invalidData = Data()
        let (sut, client) = makeSUT()

        [200, 201, 250, 299].enumerated().forEach { index, statusCode in
            expect(sut, toCompletionWith: failure(.invalidData)) {
                client.completion(withStatusCode: statusCode, data: invalidData, at: index)
            }
        }
    }
    
    func test_load_deliverNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
        let emptyJSON = makeItemJSON([])
        let (sut, client) = makeSUT()

        [200, 201, 250, 299].enumerated().forEach { index, statusCode in
            expect(sut, toCompletionWith: .success([])) {
                client.completion(withStatusCode: 200, data: emptyJSON, at: index)
            }
        }
    }
    
    func test_load_deliverItemsOn2xxHTTPResponseWithItemList() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1695979645), "2023-09-29T09:27:25+00:00"),
            username: "a username")
        
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1695980003), "2023-09-29T09:33:23+00:00"),
            username: "another username")
        
        let json = makeItemJSON([item1.itemJSON, item2.itemJSON])
        
        [200, 201, 250, 299].enumerated().forEach { index, statusCode in
            expect(sut, toCompletionWith: .success([item1.item, item2.item])) {
                client.completion(withStatusCode: statusCode, data: json, at: index)
            }
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT(client: HTTPClient = HTTPClientSpy(), url: URL = URL(string: "https://a-url")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteImageCommentLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(client: client, url: url)
        
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
    
    private func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
        return .failure(error)
    }
    
    private func expect(
        _ sut: RemoteImageCommentLoader,
        toCompletionWith expectResult: RemoteImageCommentLoader.Result,
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

