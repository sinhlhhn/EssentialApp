//
//  LoadImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 19/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

final class LoadImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage.isEmpty, true)
    }
    
    func test_loadImageData_requestStoreDataForURL() {
        let url = anyURL()
        let (sut, store) = makeSUT()
        
        _ = try? sut.loadImageData(from: url)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve(dataForURL: url)])
    }
    
    func test_loadImageData_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWithResult: failed()) {
            store.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWithResult: notFound()) {
            store.completeRetrieval(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFound() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        expect(sut, completeWithResult: .success(foundData)) {
            store.completeRetrieval(with: foundData)
        }
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func failed() -> FeedImageDataStore.RetrievalResult {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, completeWithResult expectedResult: FeedImageDataStore.RetrievalResult, action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        action()
        
        let result = Result { try sut.loadImageData(from: anyURL()) }
        switch (result, expectedResult) {
        case let (.failure(error as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
            XCTAssertEqual(error, expectedError)
        case let (.success(data), .success(expectedData)):
            XCTAssertEqual(data, expectedData)
        default:
            XCTFail("Expected result \(expectedResult) got \(result) instead")
        }
        
    }
}
