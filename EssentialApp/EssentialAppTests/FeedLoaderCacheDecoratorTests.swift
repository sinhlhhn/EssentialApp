//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Sam on 22/09/2023.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueImage()
        let sut = makeSUT(with: .success(feed))
        
        expect(sut, toCompleteWithResult: .success(feed))
    }
    
    func test_load_deliversFeedOnLoaderFailure() {
        let error = anyNSError()
        let sut = makeSUT(with: .failure(error))
        
        expect(sut, toCompleteWithResult: .failure(error))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let feed = uniqueImage()
        let cache = FeedCacheSpy()
        let sut = makeSUT(with: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)])
    }
    
    func test_load_doesNotCacheLoadedFeedOnLoaderFailure() {
        let cache = FeedCacheSpy()
        let sut = makeSUT(with: .failure(anyNSError()), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [])
    }
    
    //MARK: -Helpers:
    
    private func makeSUT(with result: FeedLoader.Result, cache: FeedCacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return sut
    }
    
    private class FeedCacheSpy: FeedCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(feed))
        }
    }
}
