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
        
        let saveExp = expectation(description: "wait for save")
        sutToSave.save(feed) { saveError in
            XCTAssertNil(saveError)
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1)
        
        expect(sutToLoad, toCompleteWithItem: feed)
    }
    
    func test_load_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let lastFeed = uniqueImageFeed().models
        
        let firstSaveExp = expectation(description: "wait for save")
        sutToPerformFirstSave.save(firstFeed) { saveError in
            XCTAssertNil(saveError)
            firstSaveExp.fulfill()
        }
        
        wait(for: [firstSaveExp], timeout: 1)
        
        let lastSaveExp = expectation(description: "wait for save")
        sutToPerformFirstSave.save(lastFeed) { saveError in
            XCTAssertNil(saveError)
            lastSaveExp.fulfill()
        }
        
        wait(for: [lastSaveExp], timeout: 1)
        
        expect(sutToPerformLoad, toCompleteWithItem: lastFeed)
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
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
