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
        case let .success(imageFeed):
            XCTAssertEqual(imageFeed.count, 8)
            imageFeed.enumerated().forEach { index, feed in
                XCTAssertEqual(feed.id, id(at: index))
                XCTAssertEqual(feed.description, description(at: index))
                XCTAssertEqual(feed.location, location(at: index))
                XCTAssertEqual(feed.imageURL, imageURL(at: index))
            }
        case let .failure(error):
            XCTFail("Expected success, got error \(error)")
        default:
            XCTFail("Expected success, got result \(String(describing: receivedResult))")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        let receivedImageResult = getImageDataFromURL()
        
        switch receivedImageResult {
        case let .success(data):
            XCTAssertEqual(data.isEmpty, false, "Expected non-empty data instead")
        case let .failure(error):
            XCTFail("Expected success got error \(error) instead")
        default:
            XCTFail("Expected success got result \(String(describing: receivedImageResult)) instead")
        }
    }
    
    //MARK: -Helpers
    
    private func getFromURL(file: StaticString = #filePath,
                            line: UInt = #line) -> Swift.Result<[FeedImage], Error>? {
        let url = feedTestServerURL
        let client = ephemeralClient()
        
        var receivedResult: Swift.Result<[FeedImage], Error>?
        
        let exp = expectation(description: "Wait for completion")
        client.get(from: url) { result in
            receivedResult = result.flatMap{ data, response in
                do {
                    return .success(try FeedItemsMapper.map(data, response))
                } catch {
                    return .failure(error)
                }
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10)
        
        return receivedResult
    }
    
    private func getImageDataFromURL(file: StaticString = #filePath, line: UInt = #line) -> Result<Data, Error>? {
        let url = feedTestServerURL.appending(path: "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        let client = ephemeralClient()
        
        var receivedResult: Result<Data, Error>?
        
        let exp = expectation(description: "Wait for completion")
        _ = client.get(from: url) { result in
            receivedResult = result.flatMap { data, response in
                do {
                    return .success(try FeedImageDataMapper.map(data, from: response))
                } catch {
                    return .failure(error)
                }
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10)
        
        return receivedResult
    }
    
    private var feedTestServerURL: URL {
        return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }
    
    private func ephemeralClient(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        trackForMemoryLeak(client, file: file, line: line)
        
        return client
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
