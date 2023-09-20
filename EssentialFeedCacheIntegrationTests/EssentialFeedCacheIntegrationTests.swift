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

    // MARK: - LocalFeedLoader Tests
    
    func test_load_deliversNoItemOnEmptyCache() {
        let feedLoader = makeFeedLoader()
        
        expect(feedLoader, toCompleteWithItem: [])
    }
    
    func test_loadFeed_deliversItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        
        expect(feedLoaderToPerformLoad, toCompleteWithItem: feed)
    }
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformFirstSave = makeFeedLoader()
        let feedLoaderToPerformLastSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let firstFeed = uniqueImageFeed().models
        let lastFeed = uniqueImageFeed().models
        
        save(firstFeed, with: feedLoaderToPerformFirstSave)
        save(lastFeed, with: feedLoaderToPerformLastSave)
        
        expect(feedLoaderToPerformLoad, toCompleteWithItem: lastFeed)
    }
    
    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feed = uniqueImage()
        
        save([feed], with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toCompleteWithItem: [feed])
    }
    
    func test_validateFeedCache_deleteFeedSavedInDistantPast() {
        let feedLoaderToPerformSave = makeFeedLoader(currentDate: .distantPast)
        let feedLoaderToPerformValidation = makeFeedLoader(currentDate: Date())
        let feed = uniqueImage()
        
        save([feed], with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toCompleteWithItem: [])
    }
    
    // MARK: - LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let feed = uniqueImage()
        let dataToSave = anyData()
        
        save([feed], with: feedLoader)
        save(dataToSave, for: feed.imageURL, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toCompleteWithItem: dataToSave, from: feed.imageURL)
        
    }
    
    func test_saveImageData_overridesItemSavedOnASeparateInstance() {
        let firstImageLoaderToPerformSave = makeImageLoader()
        let lastImageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let feed = uniqueImage()
        let firstDataToSave = anyData()
        let lastDataToSave = anyData()
        
        save([feed], with: feedLoader)
        save(firstDataToSave, for: feed.imageURL, with: firstImageLoaderToPerformSave)
        save(lastDataToSave, for: feed.imageURL, with: lastImageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toCompleteWithItem: lastDataToSave, from: feed.imageURL)
    }
    
    //MARK: -Helpers
    
    private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return sut
    }
    
    private func makeImageLoader(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithItem expectedItem: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch result {
            case let .success(receivedImages):
                XCTAssertEqual(receivedImages, expectedItem)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWithItem expectedItem: Data, from url: URL, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(receivedImages):
                XCTAssertEqual(receivedImages, expectedItem)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func save(_ data: Data, for url: URL, with sut: LocalFeedImageDataLoader, file: StaticString = #filePath, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        
        sut.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save image successfully", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func validateCache(with sut: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for validate")
        sut.validate { validationResult in
            switch validationResult {
            case .success:
                break
            case let .failure(error):
                XCTFail("Expected successful validate result, got \(error) instead")
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
