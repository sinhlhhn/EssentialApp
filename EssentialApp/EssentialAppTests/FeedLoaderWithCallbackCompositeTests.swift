//
//  FeedLoaderWithCallbackCompositeTests.swift
//  FeedLoaderWithCallbackCompositeTests
//
//  Created by Sam on 21/09/2023.
//

import XCTest
import EssentialFeed

final class FeedLoaderWithCallbackComposite: FeedLoader {
    private let primaryLoader: FeedLoader
    private let callbackLoader: FeedLoader
    
    init(primaryLoader: FeedLoader, callbackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.callbackLoader = callbackLoader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.callbackLoader.load(completion: completion)
            }
        }
    }
}

final class FeedLoaderWithCallbackCompositeTests: XCTestCase {
    
    func test_loadFeed_deliversPrimaryImageOnPrimaryLoaderSuccess() {
        let primaryImage = uniqueImage()
        let callbackImage = uniqueImage()
        let sut = makeSUT(primaryResult: .success(primaryImage), callbackResult: .success(callbackImage))
        
        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch result {
            case let .success(receivedImage):
                XCTAssertEqual(receivedImage, primaryImage)
            case let .failure(error):
                XCTFail("Expected success got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadFeed_deliversFallbackOnPrimaryLoaderFailure() {
        let callbackImage = uniqueImage()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), callbackResult: .success(callbackImage))
        
        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch result {
            case let .success(receivedImage):
                XCTAssertEqual(receivedImage, callbackImage)
            case let .failure(error):
                XCTFail("Expected success got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    //MARK: -Helpers
    
    private func makeSUT(primaryResult: FeedLoader.Result, callbackResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoaderWithCallbackComposite {
        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let callbackLoader = FeedLoaderStub(result: callbackResult)
        let sut = FeedLoaderWithCallbackComposite(primaryLoader: primaryLoader, callbackLoader: callbackLoader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(primaryLoader, file: file, line: line)
        trackForMemoryLeak(callbackLoader, file: file, line: line)
        
        return sut
    }
    
    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should has been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func uniqueImage() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://any-url")!)]
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "e", code: 1)
    }
    
    private class FeedLoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
