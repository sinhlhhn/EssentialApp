//
//  FeedLoaderWithCallbackCompositeTests.swift
//  FeedLoaderWithCallbackCompositeTests
//
//  Created by Sam on 21/09/2023.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderWithCallbackCompositeTests: XCTestCase {
    
    func test_loadFeed_deliversPrimaryImageOnPrimaryLoaderSuccess() {
        let primaryImage = uniqueImage()
        let callbackImage = uniqueImage()
        let sut = makeSUT(primaryResult: .success(primaryImage), callbackResult: .success(callbackImage))
        
        expect(sut, toCompleteWithResult: .success(primaryImage))
    }
    
    func test_loadFeed_deliversFallbackOnPrimaryLoaderFailure() {
        let callbackImage = uniqueImage()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), callbackResult: .success(callbackImage))
        
        expect(sut, toCompleteWithResult: .success(callbackImage))
    }
    
    func test_loadFeed_deliversErrorOnPrimaryAndFallbackLoaderFailure() {
        let primaryError = NSError(domain: "e", code: 1)
        let fallbackError = NSError(domain: "e", code: 2)
        let sut = makeSUT(primaryResult: .failure(primaryError), callbackResult: .failure(fallbackError))
        
        expect(sut, toCompleteWithResult: .failure(fallbackError))
    }
    
    //MARK: -Helpers
    
    private func makeSUT(primaryResult: FeedLoader.Result, callbackResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoaderWithCallbackComposite {
        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let callbackLoader = FeedLoaderStub(result: callbackResult)
        let sut = FeedLoaderWithCallbackComposite(primaryLoader: primaryLoader, fallbackLoader: callbackLoader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(primaryLoader, file: file, line: line)
        trackForMemoryLeak(callbackLoader, file: file, line: line)
        
        return sut
    }
    
    private func expect(_ sut: FeedLoaderWithCallbackComposite, toCompleteWithResult expectedResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(receivedImage), .success(expectedImage)):
                XCTAssertEqual(receivedImage, expectedImage)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError.code, expectedError.code)
                XCTAssertEqual(receivedError.domain, expectedError.domain)
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
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
