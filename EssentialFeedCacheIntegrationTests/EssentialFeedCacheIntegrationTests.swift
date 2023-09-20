//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Sam on 25/08/2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWithItem: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToSave = makeSUT()
        let sutToLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(feed, with: sutToSave)
        
        expect(sutToLoad, toCompleteWithItem: feed)
    }
    
    func test_load_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let lastFeed = uniqueImageFeed().models
        
        save(firstFeed, with: sutToPerformFirstSave)
        save(lastFeed, with: sutToPerformLastSave)
        
        expect(sutToPerformLoad, toCompleteWithItem: lastFeed)
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithItem expectedItem: [FeedImage]) {
        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch result {
            case let .success(receivedImages):
                XCTAssertEqual(receivedImages, expectedItem)
            default:
                XCTFail("Expected success with empty item, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save feed successfully", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        cacheDirectory().appending(path: "\(type(of: self)).store")
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
