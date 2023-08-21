//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 20/08/2023.
//

import XCTest
import EssentialFeed

private final class CodableFeedStore: FeedStore {
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
        
        do {
            let decoder = try JSONDecoder().decode(Cache.self, from: data)
            completion(.find(decoder.localFeed, decoder.timestamp))
        } catch {
            completion(.failure(error))
        }
        
    }
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let encoder = try JSONEncoder().encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: currentDate))
            try encoder.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func deleteCacheFeed(completion: @escaping FeedStore.DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            completion(nil)
            return
        }
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
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
        
        expect(sut, toRetrieveWithResult: .empty)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveWithResultTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveWithResult: .find(feed, timestamp))
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveWithResult: .find(feed, timestamp))
    }
    
    func test_retrieve_deliverFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalidData".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveWithResult: .failure(anyError()))
    }
    
    func test_retrieve_hasNoSideEffectOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalidData".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveWithResultTwice: .failure(anyError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let firstFeed = uniqueImageFeed().locals
        let firstTimestamp = Date.init()
        
        let secondFeed = uniqueImageFeed().locals
        let secondTimestamp = Date.init()
        
        insert(firstFeed, timestamp: firstTimestamp, to: sut)
        insert(secondFeed, timestamp: secondTimestamp, to: sut)
        
        expect(sut, toRetrieveWithResult: .find(secondFeed, secondTimestamp))
    }
    
    func test_insert_deliversFailureOnInsertionError() {
        let invalidURL = URL(string: "invalid-url")
        let sut = makeSUT(storeURL: invalidURL)
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        let exp = expectation(description: "wait for insertion")
        sut.insert(feed, currentDate: timestamp) { insertionError in
            XCTAssertNotNil(insertionError)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError)
        expect(sut, toRetrieveWithResult: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCached() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError)
        expect(sut, toRetrieveWithResult: .empty)
    }
    
    func test_delete_deliverErrorOnDeletionError() {
        let noDeletePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = delete(from: sut)
        
        XCTAssertNotNil(deletionError)
        expect(sut, toRetrieveWithResult: .empty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(url: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedStore, toRetrieveWithResult expectedResult: LoadCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for retrieval")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case let (.find(receivedImages, receivedTimestamp), .find(expectedImages, expectedTimestamp)):
                XCTAssertEqual(receivedImages, expectedImages)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp)
                
            case (.empty, .empty), (.failure, .failure): break
                
            default:
                XCTFail("Expected retrieving \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func delete(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for deletion")
        var deletionError: Error?
        sut.deleteCacheFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return deletionError
    }
    
    private func insert(_ feed: [LocalFeedImage], timestamp: Date, to sut: FeedStore) {
        let exp = expectation(description: "wait for insertion")
        
        sut.insert(feed, currentDate: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(_ sut: FeedStore, toRetrieveWithResultTwice expectedResult: LoadCacheResult) {
        expect(sut, toRetrieveWithResult: expectedResult)
        expect(sut, toRetrieveWithResult: expectedResult)
    }
    
    private func testSpecificStoreURL() -> URL {
        cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
