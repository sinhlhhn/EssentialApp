//
//  FeedItemMapperTests.swift
//  FeedItemMapperTests
//
//  Created by sinhlh on 04/08/2023.
//

import XCTest
import EssentialFeed

final class FeedItemMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let data = makeItemJSON([])
        
        try [199, 201, 300, 400].forEach { statusCode in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(data, response(with: statusCode))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidData() {
        let invalidData = Data()

        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidData, response(with: 200))
        )
    }
    
    func test_map_deliverOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyJSON = makeItemJSON([])

        let items = try FeedItemsMapper.map(emptyJSON, response(with: 200))
        XCTAssertEqual(items, [])
    }
    
    func test_map_deliverOn200HTTPResponseWithItemList() throws {
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
        
        let json = makeItemJSON([item1.itemJSON, item2.itemJSON])
        let items = try FeedItemsMapper.map(json, response(with: 200))
        
        XCTAssertEqual(items, [item1.item, item2.item])
    }
    
    //MARK: - Helpers
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (item: FeedImage, itemJSON: [String: Any]) {
        let item = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageURL)
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
}
