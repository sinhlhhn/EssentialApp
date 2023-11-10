//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 20/09/2023.
//

import XCTest
import EssentialFeed

final class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage.isEmpty, true)
    }
    
    func test_saveImage_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let imageData = anyData()
        
        sut.save(imageData, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.insert(imageData, for: url)])
    }
    
    func test_saveImage_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWithResult: failed()) {
            store.completeInsertion(with: anyNSError())
        }
    }
    
    func test_saveImage_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWithResult: .success(())) {
            store.completeInsertionSuccessfully()
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
    
    private func failed() -> FeedImageDataStore.InsertionResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, completeWithResult expectedResult: FeedImageDataStore.InsertionResult, action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for request")
        
        action()
        
        sut.save(anyData(), for: anyURL()) { result in
            switch (result, expectedResult) {
            case let (.failure(error as LocalFeedImageDataLoader.SaveError), .failure(expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(error, expectedError)
            case (.success(_), .success(_)):
                break
            default:
                XCTFail("Expected result \(expectedResult) got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}


