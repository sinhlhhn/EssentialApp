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
        
        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch result {
            case let .success(receivedImages):
                XCTAssertEqual(receivedImages, [])
            default:
                XCTFail("Expected success with empty item, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToSave = makeSUT()
        let sutToLoad = makeSUT()
        let feed = uniqueImageFeed()
        
        let saveExp = expectation(description: "wait for save")
        sutToSave.save(feed.models) { saveError in
            XCTAssertNil(saveError)
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1)
        
        let loadExp = expectation(description: "wait for load")
        sutToLoad.load { result in
            switch result {
            case let .success(receivedImages):
                XCTAssertEqual(receivedImages, feed.models)
            default:
                XCTFail("Expected success with empty item, got \(result) instead")
            }
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1)
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
