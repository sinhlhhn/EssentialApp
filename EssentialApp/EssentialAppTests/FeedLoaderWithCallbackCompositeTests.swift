//
//  FeedLoaderWithCallbackCompositeTests.swift
//  FeedLoaderWithCallbackCompositeTests
//
//  Created by Sam on 21/09/2023.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderWithCallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
    
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
}
