//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 20/08/2023.
//

import XCTest
import EssentialFeed

private final class CodableFeedStore {
    let storeURL: URL
    
    init(url: URL) {
        self.storeURL = url
    }
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        init(_ item: LocalFeedImage) {
            self.id = item.id
            self.description = item.description
            self.location = item.location
            self.url = item.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        let decoder = try! JSONDecoder().decode(Cache.self, from: data)
        completion(.find(decoder.localFeed, decoder.timestamp))
        
    }
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = try! JSONEncoder().encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: currentDate))
        try! encoder.write(to: storeURL)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
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
        let sut = makeSUT()
        
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
        let sut = makeSUT()
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        let exp = expectation(description: "wait for retrieve")
        sut.insert(feed, currentDate: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrieve { result in
                switch result {
                case let .find(receivedImages, receivedTimestamp):
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
    
    //MARK: - Helpers
    
    private func makeSUT() -> CodableFeedStore {
        let sut = CodableFeedStore(url: testSpecificStoreURL())
        trackForMemoryLeak(sut)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
