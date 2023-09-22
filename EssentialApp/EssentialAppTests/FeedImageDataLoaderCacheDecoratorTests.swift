//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Sam on 22/09/2023.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping ((SaveResult) -> Void))
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { feed in
                self?.cache.save(feed, for: url) { _ in }
                return feed
            })
        }
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.requestedURLs.isEmpty, true)
    }
    
    func test_loadImageData_loadsFromLoader() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.requestedURLs, [url])
    }
    
    func test_loadImageData_cancelsLoaderTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.canceledURLs, [url])
    }
    
    func test_loadImageData_deliversImageDataOnLoaderSuccess() {
        let data = anyData()
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        expect(sut, completeWithResult: .success(data), from: url) {
            loader.complete(with: data)
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderError() {
        let error = anyNSError()
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        expect(sut, completeWithResult: .failure(error), from: url) {
            loader.complete(with: error)
        }
    }
    
    func test_loadImageData_cachesLoadedDataOnLoaderSuccess() {
        let data = anyData()
        let url = anyURL()
        let cache = FeedImageDataCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: data)
        
        
        XCTAssertEqual(cache.messages, [.save(data, url)])
    }
    
    func test_loadImageData_doesNotCacheLoadedDataOnLoaderFailure() {
        let url = anyURL()
        let cache = FeedImageDataCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: anyNSError())
        
        
        XCTAssertEqual(cache.messages, [])
    }
    
    //MARK: -Helpers:
    
    private func makeSUT(cache: FeedImageDataCacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private class FeedImageDataCacheSpy: FeedImageDataCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(Data, URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping ((SaveResult) -> Void)) {
            messages.append(.save(data, url))
        }
    }
}
