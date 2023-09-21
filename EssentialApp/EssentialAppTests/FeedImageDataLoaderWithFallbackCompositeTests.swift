//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Sam on 21/09/2023.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
    
    init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    private final class Task: FeedImageDataLoaderTask {
        func cancel() { }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        _ = primaryLoader.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success: break
            case .failure:
                _ = self?.fallbackLoader.loadImageData(from: url) { _ in }
            }
        }
        return Task()
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssertEqual(primaryLoader.requestedURLs.isEmpty, true)
        XCTAssertEqual(fallbackLoader.requestedURLs.isEmpty, true)
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.requestedURLs, [url])
        XCTAssertEqual(fallbackLoader.requestedURLs.isEmpty, true)
    }
    
    func test_loadImageData_loadsFromFallbackLoaderOnPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { result in }
        
        primaryLoader.completeLoadImage(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.requestedURLs, [url])
        XCTAssertEqual(fallbackLoader.requestedURLs, [url])
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedImageDataLoaderWithFallbackComposite, FeedImageDataLoaderSpy, FeedImageDataLoaderSpy) {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(fallbackLoader, file: file, line: line)
        trackForMemoryLeak(primaryLoader, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should has been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "0", code: 0)
    }
    
    private func anyData() -> Data {
        return Data("any-data".utf8)
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
        
        func completeLoadImage(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
