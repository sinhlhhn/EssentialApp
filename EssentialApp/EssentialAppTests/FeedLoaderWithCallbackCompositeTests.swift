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
    
    init(primaryLoader: FeedLoader, callbackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load(completion: completion)
    }
}

final class FeedLoaderWithCallbackCompositeTests: XCTestCase {
    
    func test_loadFeed_deliversPrimaryImageOnPrimaryLoaderSuccess() {
        let primaryImage = uniqueImage()
        let callbackImage = uniqueImage()
        let primaryLoader = FeedLoaderStub(result: .success([primaryImage]))
        let callbackLoader = FeedLoaderStub(result: .success([callbackImage]))
        let sut = FeedLoaderWithCallbackComposite(primaryLoader: primaryLoader, callbackLoader: callbackLoader)
        
        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch result {
            case let .success(receivedImage):
                XCTAssertEqual(receivedImage, [primaryImage])
            case let .failure(error):
                XCTFail("Expected success got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://any-url")!)
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
