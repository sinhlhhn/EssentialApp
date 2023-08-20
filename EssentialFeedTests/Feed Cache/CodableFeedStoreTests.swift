//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 20/08/2023.
//

import XCTest
import EssentialFeed

private final class CodableFeedStore {
    
    private let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Image.store")
    
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: url) else {
            completion(.empty)
            return
        }
        
        let decoder = try! JSONDecoder().decode(Cache.self, from: data)
        completion(.success(decoder.feed, decoder.timestamp))
        
    }
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = try! JSONEncoder().encode(Cache(feed: feed, timestamp: currentDate))
        try! encoder.write(to: url)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Image.store"))
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Image.store"))
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "wait for retrieve")
        sut.retrieve { result in
            switch result {
            case .empty: break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "wait for retrieve")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver the same result, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        let exp = expectation(description: "wait for retrieve")
        sut.insert(feed, currentDate: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrieve { result in
                switch result {
                case let .success(receivedImages, receivedTimestamp):
                    XCTAssertEqual(feed, receivedImages)
                    XCTAssertEqual(timestamp, receivedTimestamp)
                default:
                    XCTFail("Expected retrieving success, got \(result) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
}
