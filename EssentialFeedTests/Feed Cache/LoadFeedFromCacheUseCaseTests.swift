//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 17/08/2023.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrieveError = anyError()
        
        let exp = expectation(description: "wait for complition")
        var receivedError: NSError?
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error as NSError
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        store.completeRetrieve(with: retrieveError)
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(retrieveError.code, receivedError?.code)
    }
    
//    func test_load_deliversEmptyImageOnEmptyCache() {
//        let (sut, store) = makeSUT()
//        var receivedImages = [FeedImage]()
//
//        let exp = expectation(description: "wait for complition")
//        sut.load { error in
//
//            exp.fulfill()
//        }
//
//        store.completeSuccessRetrieval()
//
//        wait(for: [exp], timeout: 1)
//
//        XCTAssertEqual(receivedImages, [])
//    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyError() -> NSError {
        NSError(domain: "any-error", code: 1)
    }
}
