//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 29/09/2023.
//

import XCTest
import EssentialFeed

final class ImageCommentsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let data = makeItemJSON([])
        
        try [199, 300, 400].enumerated().forEach { index, statusCode in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(data, response(with: statusCode))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidData() throws {
        let invalidData = Data()

        try [200, 201, 250, 299].forEach { statusCode in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidData, response(with: statusCode))
            )
        }
    }
    
    func test_map_deliverNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
        let emptyJSON = makeItemJSON([])

        try [200, 201, 250, 299].forEach { statusCode in
            let result = try ImageCommentsMapper.map(emptyJSON, response(with: statusCode))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_load_deliverItemsOn2xxHTTPResponseWithItemList() throws {
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
        
        try [200, 201, 250, 299].forEach { statusCode in
            let result = try ImageCommentsMapper.map(json, response(with: statusCode))
            XCTAssertEqual(result, [item1.item, item2.item])
        }
    }
    
    //MARK: - Helpers
    
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
    
    private func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
        return .failure(error)
    }
}

