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
        
        _ = sut.loadImageData(from: url) { _ in }
        
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
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancelingTask() {
        let (sut, store) = makeSUT()
        
        var capturedResult = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { result in
            capturedResult.append(result)
        }
        
        task.cancel()
        
        store.completeRetrieval(with: anyData())
        store.completeRetrieval(with: anyNSError())
        store.completeRetrieval(with: .none)
        
        XCTAssertEqual(capturedResult.isEmpty, true)
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { result in
            capturedResult.append(result)
        }
        
        sut = nil
        
        store.completeRetrieval(with: anyData())
        store.completeRetrieval(with: anyNSError())
        store.completeRetrieval(with: .none)
        
        XCTAssertEqual(capturedResult.isEmpty, true)
    }
    
    func test_saveImage_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let imageData = anyData()
        
        sut.save(imageData, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.insert(imageData, for: url)])
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
        let exp = expectation(description: "wait for request")
        
        _ = sut.loadImageData(from: anyURL()) { result in
            switch (result, expectedResult) {
            case let (.failure(error as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(error, expectedError)
            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData)
            default:
                XCTFail("Expected result \(expectedResult) got \(result) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
