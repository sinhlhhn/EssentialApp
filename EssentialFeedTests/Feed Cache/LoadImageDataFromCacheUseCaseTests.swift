//
//  LoadImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sam on 19/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataFroURL url: URL, completion: @escaping (Result) -> ())
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    private class LocalFeedImageDataLoaderTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> ())?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        let task = LocalFeedImageDataLoaderTask(completion: completion)
        
        store.retrieve(dataFroURL: url) { result in
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(Error.notFound)
                }
            )
        }
        
        return task
    }
}

final class LoadImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage.isEmpty, true)
    }
    
    func test_loadImageData_requestStoreDataForURL() {
        let url = anyURL()
        let (sut, store) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.retrieve(dataForURL: url)])
    }
    
    func test_loadImageData_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWithResult: failed()) {
            store.completion(with: anyNSError())
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWithResult: notFound()) {
            store.completion(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFound() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        expect(sut, completeWithResult: .success(foundData)) {
            store.completion(with: foundData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverDataAfterCancelingTask() {
        let (sut, store) = makeSUT()
        
        var capturedResult = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { result in
            capturedResult.append(result)
        }
        
        task.cancel()
        
        store.completion(with: anyData())
        store.completion(with: anyNSError())
        store.completion(with: .none)
        
        XCTAssertEqual(capturedResult.isEmpty, true)
    }
    
    //MARK: -Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func failed() -> FeedImageDataStore.Result {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    private func notFound() -> FeedImageDataStore.Result {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, completeWithResult expectedResult: FeedImageDataStore.Result, action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for request")
        
        _ = sut.loadImageData(from: anyURL()) { result in
            switch (result, expectedResult) {
            case let (.failure(error as LocalFeedImageDataLoader.Error), .failure(expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(error, expectedError)
            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData)
            default:
                XCTFail("Expected result \(expectedResult) got \(result) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private class FeedStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
        }
        
        private var completions = [(FeedImageDataStore.Result) -> Void]()
        private(set) var receivedMessage = [Message]()
        
        func retrieve(dataFroURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> ()) {
            receivedMessage.append(.retrieve(dataForURL: url))
            completions.append(completion)
        }
        
        func completion(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func completion(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
}
