//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Sam on 22/09/2023.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.requestURLs.isEmpty, true)
    }
    
    func test_loadImageData_loadsFromLoader() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.requestURLs, [url])
    }
    
    func test_loadImageData_cancelsLoaderTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.canceledRequests, [url])
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
    
    //MARK: -Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func expect(_ sut: FeedImageDataLoader, completeWithResult expectedResult: FeedImageDataLoader.Result, from url: URL, action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load")
        _ = sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError.code, expectedError.code)
                XCTAssertEqual(receivedError.domain, expectedError.domain)
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private class FeedImageDataLoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> ())]()
        
        var requestURLs: [URL] {
            messages.map { $0.url }
        }
        
        private(set) var canceledRequests = [URL]()
        
        private class Task: FeedImageDataLoaderTask {
            var onCancel: () -> Void
            
            init(onCancel: @escaping () -> Void) {
                self.onCancel = onCancel
            }
            
            func cancel() {
                onCancel()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.canceledRequests.append(url)
            }
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}