//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Sam on 22/09/2023.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

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
    
    //MARK: -Helpers:
    
    private func makeSUT(with result: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return sut
    }
}
