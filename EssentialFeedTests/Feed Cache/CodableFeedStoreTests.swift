//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 20/08/2023.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
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
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        let insertionError = insert(feed, timestamp: timestamp, to: sut)
        
        XCTAssertNil(insertionError)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        let insertionError = insert(feed, timestamp: timestamp, to: sut)
        
        XCTAssertNil(insertionError)
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
        
        let insertionError = insert(feed, timestamp: timestamp, to: sut)
        
        XCTAssertNotNil(insertionError)
    }
    
    func test_insert_hasNoSideEffectOnInsertionError() {
        let invalidURL = URL(string: "invalid-url")
        let sut = makeSUT(storeURL: invalidURL)
        let feed = uniqueImageFeed().locals
        let timestamp = Date.init()
        
        insert(feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveWithResult: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert(uniqueImageFeed().locals, timestamp: Date(), to: sut)
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        delete(from: sut)
        
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
        let sut = makeSUT(storeURL: noDeletePermissionURL())
        
        let deletionError = delete(from: sut)
        
        XCTAssertNotNil(deletionError)
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() {
        let sut = makeSUT(storeURL: noDeletePermissionURL())
        
        delete(from: sut)
        
        expect(sut, toRetrieveWithResult: .empty)
    }
    
    func test_storeSideEffect_runSerially() {
        let sut = makeSUT()
        var capturedExpectations = [XCTestExpectation]()
        
        let op1 = expectation(description: "Wait for op1")
        sut.insert(uniqueImageFeed().locals, currentDate: Date()) { _ in
            capturedExpectations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Wait for op2")
        sut.deleteCacheFeed { _ in
            capturedExpectations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Wait for op3")
        sut.insert(uniqueImageFeed().locals, currentDate: Date()) { _ in
            capturedExpectations.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(capturedExpectations, [op1, op2, op3], "Expected side-effects run in serially but operation finished in the wrong oder")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(url: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func noDeletePermissionURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
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
