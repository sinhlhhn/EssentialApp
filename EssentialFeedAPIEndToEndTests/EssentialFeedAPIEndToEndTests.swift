//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Sam on 13/08/2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEnd() {
        let receivedResult = getFromURL()
        
        switch receivedResult {
        case let .success(items):
            XCTAssertEqual(items.count, 8)
            items.enumerated().forEach { index, item in
                XCTAssertEqual(item.id, id(at: index))
                XCTAssertEqual(item.description, description(at: index))
                XCTAssertEqual(item.location, location(at: index))
                XCTAssertEqual(item.imageURL, imageURL(at: index))
            }
        case let .failure(error):
            XCTFail("Expected success, got error \(error)")
        default:
            XCTFail("Expected success, got result \(String(describing: receivedResult))")
        }
    }
    
    //MARK: -Helpers
    
    private func getFromURL(file: StaticString = #filePath,
                            line: UInt = #line) -> LoadFeedResult? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        
        var receivedResult: LoadFeedResult?
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 20)
        
        return receivedResult
    }
    
    private func id(at index: Int) -> UUID {
            return UUID(uuidString: [
                "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
                "BA298A85-6275-48D3-8315-9C8F7C1CD109",
                "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
                "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
                "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
                "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
                "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
                "F79BD7F8-063F-46E2-8147-A67635C3BB01"
            ][index])!
        }

        private func description(at index: Int) -> String? {
            return [
                "Description 1",
                nil,
                "Description 3",
                nil,
                "Description 5",
                "Description 6",
                "Description 7",
                "Description 8"
            ][index]
        }

        private func location(at index: Int) -> String? {
            return [
                "Location 1",
                "Location 2",
                nil,
                nil,
                "Location 5",
                "Location 6",
                "Location 7",
                "Location 8"
            ][index]
        }

        private func imageURL(at index: Int) -> URL {
            return URL(string: "https://url-\(index+1).com")!
        }
}
