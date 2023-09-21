//
//  FeedImageDataLoaderWithFallbackTests.swift
//  EssentialAppTests
//
//  Created by Sam on 21/09/2023.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallback: FeedImageDataLoader {
    init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {}
    
    private final class Task: FeedImageDataLoaderTask {
        func cancel() { }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        
        return Task()
    }
}

final class FeedImageDataLoaderWithFallbackTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let _ = FeedImageDataLoaderWithFallback(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        XCTAssertEqual(primaryLoader.requestedURLs.isEmpty, true)
        XCTAssertEqual(fallbackLoader.requestedURLs.isEmpty, true)
    }
    
    private class FeedImageDataLoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> ())]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private final class Task: FeedImageDataLoaderTask {
            func cancel() { }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
    }
}
